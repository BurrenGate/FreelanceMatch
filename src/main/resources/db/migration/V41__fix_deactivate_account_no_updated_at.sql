-- V41: Fix deactivate_account function - remove updated_at column

DROP FUNCTION IF EXISTS account_management.deactivate_account(VARCHAR);

CREATE OR REPLACE FUNCTION account_management.deactivate_account(
    p_email VARCHAR(255)
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_account_id BIGINT;
    v_profile_id BIGINT;
    v_role_id INTEGER;
    v_active_jobs_count INTEGER;
    v_active_contracts_count INTEGER;
BEGIN
    -- Get account and profile info
    SELECT a.id, a.role_id, p.id
    INTO v_account_id, v_role_id, v_profile_id
    FROM accounts a
    LEFT JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_email;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account not found';
    END IF;
    
    -- Check if account is already inactive
    IF (SELECT status FROM accounts WHERE id = v_account_id) = 'inactive' THEN
        RAISE EXCEPTION 'Account is already inactive';
    END IF;
    
    -- For clients (role_id = 1): check if they have jobs in IN_PROGRESS status
    IF v_role_id = 1 THEN
        SELECT COUNT(*) INTO v_active_jobs_count
        FROM jobs j
        JOIN job_statuses js ON js.id = j.status_id
        WHERE j.client_id = v_profile_id
          AND js.status_name = 'IN_PROGRESS';
        
        IF v_active_jobs_count > 0 THEN
            RAISE EXCEPTION 'Cannot deactivate account: you have % active job(s) in progress', v_active_jobs_count;
        END IF;
    END IF;
    
    -- For freelancers (role_id = 2): check if they have active contracts
    IF v_role_id = 2 THEN
        SELECT COUNT(*) INTO v_active_contracts_count
        FROM contracts
        WHERE freelancer_id = v_profile_id
          AND status = 'active';
        
        IF v_active_contracts_count > 0 THEN
            RAISE EXCEPTION 'Cannot deactivate account: you have % active contract(s)', v_active_contracts_count;
        END IF;
    END IF;
    
    -- Deactivate account
    UPDATE accounts
    SET status = 'inactive'
    WHERE id = v_account_id;
    
    RAISE NOTICE 'Account % deactivated successfully', v_account_id;
    
    RETURN 'ACCOUNT_DEACTIVATED';
END;
$$;

COMMENT ON FUNCTION account_management.deactivate_account IS 'Deactivate account if no active jobs or contracts';
