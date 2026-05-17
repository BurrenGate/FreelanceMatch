-- V33: Contract cancellation with confirmation from both parties

-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS contract_management;

-- Add cancellation fields to contracts table
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS cancellation_requested_by BIGINT REFERENCES profiles(id);
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS cancellation_requested_at TIMESTAMP;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

-- Function to request contract cancellation
CREATE OR REPLACE FUNCTION contract_management.request_contract_cancellation(
    p_contract_id BIGINT,
    p_requester_id BIGINT,
    p_reason TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_contract_status VARCHAR(50);
    v_freelancer_id BIGINT;
    v_client_id BIGINT;
    v_job_id BIGINT;
BEGIN
    -- Get contract details
    SELECT c.status, c.freelancer_id, j.client_id, c.job_id
    INTO v_contract_status, v_freelancer_id, v_client_id, v_job_id
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract % not found', p_contract_id;
    END IF;
    
    -- Check if contract is active
    IF v_contract_status != 'active' THEN
        RAISE EXCEPTION 'Only active contracts can be cancelled. Current status: %', v_contract_status;
    END IF;
    
    -- Check if requester is participant
    IF p_requester_id != v_freelancer_id AND p_requester_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not a participant of contract %', p_requester_id, p_contract_id;
    END IF;
    
    -- Update contract with cancellation request
    UPDATE contracts
    SET cancellation_requested_by = p_requester_id,
        cancellation_requested_at = NOW(),
        cancellation_reason = p_reason
    WHERE id = p_contract_id;
    
    RAISE NOTICE 'Cancellation requested for contract % by user %', p_contract_id, p_requester_id;
    
    RETURN 'PENDING_CONFIRMATION';
END;
$$;

-- Function to confirm contract cancellation
CREATE OR REPLACE FUNCTION contract_management.confirm_contract_cancellation(
    p_contract_id BIGINT,
    p_confirmer_id BIGINT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_contract_status VARCHAR(50);
    v_freelancer_id BIGINT;
    v_client_id BIGINT;
    v_job_id BIGINT;
    v_cancellation_requested_by BIGINT;
BEGIN
    -- Get contract details
    SELECT c.status, c.freelancer_id, j.client_id, c.job_id, c.cancellation_requested_by
    INTO v_contract_status, v_freelancer_id, v_client_id, v_job_id, v_cancellation_requested_by
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract % not found', p_contract_id;
    END IF;
    
    -- Check if contract is active
    IF v_contract_status != 'active' THEN
        RAISE EXCEPTION 'Only active contracts can be cancelled. Current status: %', v_contract_status;
    END IF;
    
    -- Check if there is a pending cancellation request
    IF v_cancellation_requested_by IS NULL THEN
        RAISE EXCEPTION 'No cancellation request found for contract %', p_contract_id;
    END IF;
    
    -- Check if confirmer is the other party (not the requester)
    IF p_confirmer_id = v_cancellation_requested_by THEN
        RAISE EXCEPTION 'Cannot confirm your own cancellation request';
    END IF;
    
    -- Check if confirmer is participant
    IF p_confirmer_id != v_freelancer_id AND p_confirmer_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not a participant of contract %', p_confirmer_id, p_contract_id;
    END IF;
    
    -- Cancel the contract
    UPDATE contracts
    SET status = 'cancelled'
    WHERE id = p_contract_id;
    
    -- Update job status back to OPEN
    UPDATE jobs
    SET status_id = (SELECT id FROM job_statuses WHERE status_name = 'OPEN')
    WHERE id = v_job_id;
    
    -- Reject all other pending proposals for this job
    UPDATE proposals
    SET status = 'rejected'
    WHERE job_id = v_job_id AND status = 'pending';
    
    RAISE NOTICE 'Contract % cancelled and job % reopened', p_contract_id, v_job_id;
    
    RETURN 'CANCELLED';
END;
$$;

-- Function to reject cancellation request
CREATE OR REPLACE FUNCTION contract_management.reject_cancellation_request(
    p_contract_id BIGINT,
    p_rejecter_id BIGINT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_contract_status VARCHAR(50);
    v_freelancer_id BIGINT;
    v_client_id BIGINT;
    v_cancellation_requested_by BIGINT;
BEGIN
    -- Get contract details
    SELECT c.status, c.freelancer_id, j.client_id, c.cancellation_requested_by
    INTO v_contract_status, v_freelancer_id, v_client_id, v_cancellation_requested_by
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract % not found', p_contract_id;
    END IF;
    
    -- Check if there is a pending cancellation request
    IF v_cancellation_requested_by IS NULL THEN
        RAISE EXCEPTION 'No cancellation request found for contract %', p_contract_id;
    END IF;
    
    -- Check if rejecter is the other party (not the requester)
    IF p_rejecter_id = v_cancellation_requested_by THEN
        RAISE EXCEPTION 'Cannot reject your own cancellation request';
    END IF;
    
    -- Check if rejecter is participant
    IF p_rejecter_id != v_freelancer_id AND p_rejecter_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not a participant of contract %', p_rejecter_id, p_contract_id;
    END IF;
    
    -- Clear cancellation request
    UPDATE contracts
    SET cancellation_requested_by = NULL,
        cancellation_requested_at = NULL,
        cancellation_reason = NULL
    WHERE id = p_contract_id;
    
    RAISE NOTICE 'Cancellation request rejected for contract %', p_contract_id;
    
    RETURN 'REQUEST_REJECTED';
END;
$$;

-- Function to get contract with cancellation info
CREATE OR REPLACE FUNCTION contract_management.get_contract_details(
    p_contract_id BIGINT,
    p_user_id BIGINT
)
RETURNS TABLE (
    contract_id BIGINT,
    job_id BIGINT,
    job_title VARCHAR(255),
    freelancer_id BIGINT,
    freelancer_name TEXT,
    client_id BIGINT,
    client_name TEXT,
    total_amount DECIMAL(15,2),
    status VARCHAR(50),
    cancellation_requested_by BIGINT,
    cancellation_requester_name TEXT,
    cancellation_requested_at TIMESTAMP,
    cancellation_reason TEXT,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_freelancer_id BIGINT;
    v_client_id BIGINT;
BEGIN
    -- Get contract participants
    SELECT c.freelancer_id, j.client_id
    INTO v_freelancer_id, v_client_id
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract % not found', p_contract_id;
    END IF;
    
    -- Check if user is participant
    IF p_user_id != v_freelancer_id AND p_user_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not a participant of contract %', p_user_id, p_contract_id;
    END IF;
    
    -- Return contract details
    RETURN QUERY
    SELECT 
        c.id AS contract_id,
        c.job_id,
        j.title AS job_title,
        c.freelancer_id,
        CONCAT(fp.first_name, ' ', fp.last_name) AS freelancer_name,
        j.client_id,
        CONCAT(cp.first_name, ' ', cp.last_name) AS client_name,
        c.total_amount,
        c.status,
        c.cancellation_requested_by,
        CASE 
            WHEN c.cancellation_requested_by IS NOT NULL THEN
                CONCAT(rp.first_name, ' ', rp.last_name)
            ELSE NULL
        END AS cancellation_requester_name,
        c.cancellation_requested_at,
        c.cancellation_reason,
        c.created_at
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    JOIN profiles fp ON fp.id = c.freelancer_id
    JOIN profiles cp ON cp.id = j.client_id
    LEFT JOIN profiles rp ON rp.id = c.cancellation_requested_by
    WHERE c.id = p_contract_id;
END;
$$;

COMMENT ON FUNCTION contract_management.request_contract_cancellation IS 'Request contract cancellation (requires confirmation from other party)';
