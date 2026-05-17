-- V5: This script provides functions for managing user accounts,
-- including password changes, login tracking, and deactivation.

CREATE SCHEMA IF NOT EXISTS account_management;

-- Function to change a user's password after verifying the old password.
CREATE OR REPLACE FUNCTION account_management.change_password(
    p_email VARCHAR(255),
    p_old_password_hash VARCHAR(255),
    p_new_password_hash VARCHAR(255)
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_account_id BIGINT;
    v_current_password_hash VARCHAR(255);
BEGIN
    -- Retrieve the account ID and current password hash.
    SELECT id, password_hash INTO v_account_id, v_current_password_hash
    FROM accounts
    WHERE email = p_email;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account with email "%" not found.', p_email;
    END IF;

    -- Verify that the old password is correct.
    IF v_current_password_hash != p_old_password_hash THEN
        RAISE EXCEPTION 'Incorrect current password provided.';
    END IF;

    -- Update the password hash.
    UPDATE accounts
    SET password_hash = p_new_password_hash
    WHERE id = v_account_id;

    RAISE NOTICE 'Password changed successfully for account ID %.', v_account_id;

    RETURN 'PASSWORD_CHANGED';
END;
$$;
COMMENT ON FUNCTION account_management.change_password(VARCHAR, VARCHAR, VARCHAR)
IS 'Changes a user''s password after verifying the old password hash.';

-- Function to update the last login timestamp for a user.
CREATE OR REPLACE FUNCTION account_management.update_last_login(
    p_email VARCHAR(255)
)
RETURNS TIMESTAMP
LANGUAGE plpgsql
AS $$
DECLARE
    v_last_login TIMESTAMP;
BEGIN
    -- Update the last_login timestamp and return the new value.
    UPDATE accounts
    SET last_login = NOW()
    WHERE email = p_email
    RETURNING last_login INTO v_last_login;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account with email "%" not found.', p_email;
    END IF;

    RETURN v_last_login;
END;
$$;
COMMENT ON FUNCTION account_management.update_last_login(VARCHAR)
IS 'Updates the last_login timestamp for a user upon successful login.';

-- Function to deactivate a user's account.
-- Prevents deactivation if the user has active jobs or contracts.
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
    -- Get account, profile, and role information.
    SELECT a.id, a.role_id, p.id
    INTO v_account_id, v_role_id, v_profile_id
    FROM accounts a
    LEFT JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_email;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account with email "%" not found.', p_email;
    END IF;

    -- Check if the account is already inactive.
    IF (SELECT status FROM accounts WHERE id = v_account_id) = 'inactive' THEN
        RAISE EXCEPTION 'Account is already inactive.';
    END IF;

    -- If the user is a client, check for active jobs.
    IF v_role_id = 1 THEN
        SELECT COUNT(*) INTO v_active_jobs_count
        FROM jobs j
        JOIN job_statuses js ON js.id = j.status_id
        WHERE j.client_id = v_profile_id
          AND js.status_name = 'IN_PROGRESS';

        IF v_active_jobs_count > 0 THEN
            RAISE EXCEPTION 'Cannot deactivate account: you have % active job(s) in progress.', v_active_jobs_count;
        END IF;
    END IF;

    -- If the user is a freelancer, check for active contracts.
    IF v_role_id = 2 THEN
        SELECT COUNT(*) INTO v_active_contracts_count
        FROM contracts
        WHERE freelancer_id = v_profile_id
          AND status = 'active';

        IF v_active_contracts_count > 0 THEN
            RAISE EXCEPTION 'Cannot deactivate account: you have % active contract(s).', v_active_contracts_count;
        END IF;
    END IF;

    -- Deactivate the account.
    UPDATE accounts
    SET status = 'inactive'
    WHERE id = v_account_id;

    RAISE NOTICE 'Account ID % has been deactivated successfully.', v_account_id;

    RETURN 'ACCOUNT_DEACTIVATED';
END;
$$;
COMMENT ON FUNCTION account_management.deactivate_account(VARCHAR)
IS 'Deactivates a user account, preventing deactivation if there are active jobs or contracts.';
