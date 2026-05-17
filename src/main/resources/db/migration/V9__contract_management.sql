-- V9: This script enhances contract management by introducing a formal cancellation workflow,
-- allowing either party to request and confirm a contract's termination.

CREATE SCHEMA IF NOT EXISTS contract_management;

-- Add columns to the contracts table to support the cancellation workflow.
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS cancellation_requested_by BIGINT REFERENCES profiles(id);
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS cancellation_requested_at TIMESTAMP;
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS cancellation_reason TEXT;

-- Function to initiate a contract cancellation request.
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
BEGIN
    -- Get contract details to validate the request.
    SELECT c.status, c.freelancer_id, j.client_id
    INTO v_contract_status, v_freelancer_id, v_client_id
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract with ID % not found.', p_contract_id;
    END IF;

    -- Ensure the contract is active.
    IF v_contract_status != 'active' THEN
        RAISE EXCEPTION 'Only active contracts can be cancelled. Current status: %', v_contract_status;
    END IF;

    -- Ensure the requester is a participant in the contract.
    IF p_requester_id != v_freelancer_id AND p_requester_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not a participant in contract %.', p_requester_id, p_contract_id;
    END IF;

    -- Record the cancellation request.
    UPDATE contracts
    SET cancellation_requested_by = p_requester_id,
        cancellation_requested_at = NOW(),
        cancellation_reason = p_reason
    WHERE id = p_contract_id;

    RAISE NOTICE 'Cancellation requested for contract % by user %.', p_contract_id, p_requester_id;

    RETURN 'PENDING_CONFIRMATION';
END;
$$;
COMMENT ON FUNCTION contract_management.request_contract_cancellation(BIGINT, BIGINT, TEXT)
IS 'Allows a participant to request the cancellation of an active contract.';

-- Function to confirm a pending contract cancellation request.
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
    -- Get contract details to validate the confirmation.
    SELECT c.status, c.freelancer_id, j.client_id, c.job_id, c.cancellation_requested_by
    INTO v_contract_status, v_freelancer_id, v_client_id, v_job_id, v_cancellation_requested_by
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract with ID % not found.', p_contract_id;
    END IF;

    -- Ensure there is a pending cancellation request.
    IF v_cancellation_requested_by IS NULL THEN
        RAISE EXCEPTION 'No pending cancellation request found for contract %.', p_contract_id;
    END IF;

    -- The confirmer must be the other party.
    IF p_confirmer_id = v_cancellation_requested_by THEN
        RAISE EXCEPTION 'You cannot confirm your own cancellation request.';
    END IF;

    -- The confirmer must be a participant.
    IF p_confirmer_id != v_freelancer_id AND p_confirmer_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not a participant in contract %.', p_confirmer_id, p_contract_id;
    END IF;

    -- Update the contract and job statuses.
    UPDATE contracts SET status = 'cancelled' WHERE id = p_contract_id;
    UPDATE jobs SET status_id = (SELECT id FROM job_statuses WHERE status_name = 'OPEN') WHERE id = v_job_id;

    RAISE NOTICE 'Contract % has been cancelled. Job % has been reopened.', p_contract_id, v_job_id;

    RETURN 'CANCELLED';
END;
$$;
COMMENT ON FUNCTION contract_management.confirm_contract_cancellation(BIGINT, BIGINT)
IS 'Allows a participant to confirm a pending cancellation request, terminating the contract.';

-- Function to reject a pending contract cancellation request.
CREATE OR REPLACE FUNCTION contract_management.reject_cancellation_request(
    p_contract_id BIGINT,
    p_rejecter_id BIGINT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_freelancer_id BIGINT;
    v_client_id BIGINT;
    v_cancellation_requested_by BIGINT;
BEGIN
    -- Get contract details to validate the rejection.
    SELECT c.freelancer_id, j.client_id, c.cancellation_requested_by
    INTO v_freelancer_id, v_client_id, v_cancellation_requested_by
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract with ID % not found.', p_contract_id;
    END IF;

    -- Ensure there is a pending cancellation request.
    IF v_cancellation_requested_by IS NULL THEN
        RAISE EXCEPTION 'No pending cancellation request found for contract %.', p_contract_id;
    END IF;

    -- The rejecter must be the other party.
    IF p_rejecter_id = v_cancellation_requested_by THEN
        RAISE EXCEPTION 'You cannot reject your own cancellation request.';
    END IF;

    -- The rejecter must be a participant.
    IF p_rejecter_id != v_freelancer_id AND p_rejecter_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not a participant in contract %.', p_rejecter_id, p_contract_id;
    END IF;

    -- Clear the cancellation request fields.
    UPDATE contracts
    SET cancellation_requested_by = NULL,
        cancellation_requested_at = NULL,
        cancellation_reason = NULL
    WHERE id = p_contract_id;

    RAISE NOTICE 'Cancellation request for contract % has been rejected.', p_contract_id;

    RETURN 'REQUEST_REJECTED';
END;
$$;
COMMENT ON FUNCTION contract_management.reject_cancellation_request(BIGINT, BIGINT)
IS 'Allows a participant to reject a pending cancellation request, keeping the contract active.';

-- Function to get detailed information about a contract, including cancellation status.
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
    -- Get contract participants to verify access.
    SELECT c.freelancer_id, j.client_id
    INTO v_freelancer_id, v_client_id
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract with ID % not found.', p_contract_id;
    END IF;

    -- Ensure the user is a participant.
    IF p_user_id != v_freelancer_id AND p_user_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not authorized to view contract %.', p_user_id, p_contract_id;
    END IF;

    -- Return the contract details.
    RETURN QUERY
    SELECT
        c.id, c.job_id, j.title, c.freelancer_id,
        (fp.first_name || ' ' || fp.last_name)::TEXT,
        j.client_id,
        (cp.first_name || ' ' || cp.last_name)::TEXT,
        c.total_amount, c.status, c.cancellation_requested_by,
        (SELECT (rp.first_name || ' ' || rp.last_name)::TEXT FROM profiles rp WHERE rp.id = c.cancellation_requested_by),
        c.cancellation_requested_at, c.cancellation_reason, c.created_at
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    JOIN profiles fp ON fp.id = c.freelancer_id
    JOIN profiles cp ON cp.id = j.client_id
    WHERE c.id = p_contract_id;
END;
$$;
COMMENT ON FUNCTION contract_management.get_contract_details(BIGINT, BIGINT)
IS 'Retrieves detailed information about a contract for one of its participants.';

-- Trigger to manage job and proposal statuses when a contract is created.
CREATE OR REPLACE FUNCTION contract_management.trg_fn_contract_created()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    -- Set the job status to IN_PROGRESS.
    UPDATE jobs SET status_id = (SELECT id FROM job_statuses WHERE status_name = 'IN_PROGRESS')
    WHERE id = NEW.job_id AND status_id = (SELECT id FROM job_statuses WHERE status_name = 'OPEN');

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Job % is not in OPEN state.', NEW.job_id;
    END IF;

    -- Accept the proposal that led to this contract.
    UPDATE proposals SET status = 'accepted'
    WHERE job_id = NEW.job_id AND freelancer_id = NEW.freelancer_id;

    -- Reject all other pending proposals for this job.
    UPDATE proposals SET status = 'rejected'
    WHERE job_id = NEW.job_id AND freelancer_id != NEW.freelancer_id AND status = 'pending';

    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_contract_created ON contracts;
CREATE TRIGGER trg_contract_created AFTER INSERT ON contracts
    FOR EACH ROW EXECUTE FUNCTION contract_management.trg_fn_contract_created();
COMMENT ON TRIGGER trg_contract_created ON contracts
IS 'When a contract is created, this trigger updates the job status and accepts/rejects relevant proposals.';

-- Trigger to manage job status and payment when a contract is completed.
CREATE OR REPLACE FUNCTION contract_management.trg_fn_contract_completed()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF OLD.status = 'active' AND NEW.status = 'completed' THEN
        -- Set the job status to COMPLETED.
        UPDATE jobs SET status_id = (SELECT id FROM job_statuses WHERE status_name = 'COMPLETED')
        WHERE id = NEW.job_id;

        -- Create a payment transaction for the full contract amount.
        INSERT INTO transactions (contract_id, amount, type)
        VALUES (NEW.id, NEW.total_amount, 'payment');
    END IF;
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_contract_completed ON contracts;
CREATE TRIGGER trg_contract_completed AFTER UPDATE OF status ON contracts
    FOR EACH ROW EXECUTE FUNCTION contract_management.trg_fn_contract_completed();
COMMENT ON TRIGGER trg_contract_completed ON contracts
IS 'When a contract is completed, this trigger updates the job status and creates a final payment transaction.';
