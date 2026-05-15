-- V28: Fix finalize_proposal_and_create_contract procedure to match contracts table schema

-- Drop and recreate the procedure with correct column names
CREATE OR REPLACE PROCEDURE job_market.finalize_proposal_and_create_contract(p_proposal_id BIGINT)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_proposal_id BIGINT;
    v_job_id BIGINT;
    v_freelancer_id BIGINT;
    v_bid_amount DECIMAL(15, 2);
    v_proposal_status VARCHAR(50);
BEGIN
    -- 1. Get proposal details
    SELECT id, job_id, freelancer_id, bid_amount, status
    INTO v_proposal_id, v_job_id, v_freelancer_id, v_bid_amount, v_proposal_status
    FROM proposals
    WHERE id = p_proposal_id;
    
    -- 2. Verify proposal exists
    IF v_proposal_id IS NULL THEN
        RAISE EXCEPTION 'Proposal with ID % does not exist.', p_proposal_id;
    END IF;
    
    -- 3. Check if proposal is in pending status
    IF v_proposal_status != 'pending' THEN
        RAISE EXCEPTION 'Proposal with ID % is not in pending status. Current status: %', p_proposal_id, v_proposal_status;
    END IF;
    
    -- 4. Create contract (using correct column names: job_id, freelancer_id, total_amount, status)
    INSERT INTO contracts (
        job_id,
        freelancer_id,
        total_amount,
        status
    )
    VALUES (
        v_job_id,
        v_freelancer_id,
        v_bid_amount,
        'active'
    );
    
    -- 5. Update proposal status to 'accepted'
    UPDATE proposals
    SET status = 'accepted'
    WHERE id = p_proposal_id;
    
    -- 6. Reject all other proposals for this job
    UPDATE proposals
    SET status = 'rejected'
    WHERE job_id = v_job_id AND id != p_proposal_id AND status = 'pending';
    
    -- 7. Update job status to IN_PROGRESS
    UPDATE jobs
    SET status_id = (
        SELECT id FROM job_statuses WHERE status_name = 'IN_PROGRESS'
    )
    WHERE id = v_job_id;
    
    RAISE NOTICE 'Proposal % finalized. Contract created and job status updated to IN_PROGRESS', p_proposal_id;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error finalizing proposal %: %', p_proposal_id, SQLERRM;
END;
$$;

COMMENT ON PROCEDURE job_market.finalize_proposal_and_create_contract IS 'Accept a proposal, create contract, reject other proposals, and update job status to IN_PROGRESS';
