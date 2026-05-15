-- ============================================================================
-- Migration V15: Create missing procedures and functions for freelancer platform
-- ============================================================================

-- 1. get_active_jobs_count - Count active jobs for a profile
-- Returns the count of jobs that have a status of 'OPEN'
CREATE OR REPLACE FUNCTION job_market.get_active_jobs_count(p_profile_id BIGINT)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(j.id) INTO v_count
    FROM jobs j
    JOIN job_statuses js ON js.id = j.status_id
    WHERE j.client_id = p_profile_id AND js.status_name = 'OPEN';
    
    RETURN COALESCE(v_count, 0);
END;
$$;


-- 2. get_freelancer_rating - Get the average rating for a freelancer
-- Returns the average numerical rating (1-5 scale)
CREATE OR REPLACE FUNCTION job_market.get_freelancer_rating(p_profile_id BIGINT)
    RETURNS NUMERIC
    LANGUAGE plpgsql
AS $$
DECLARE
    v_rating NUMERIC;
BEGIN
    SELECT COALESCE(AVG(r.rating), 0)
    INTO v_rating
    FROM reviews r
    JOIN contracts c ON r.contract_id = c.id
    WHERE c.freelancer_id = p_profile_id 
      AND r.reviewer_id != p_profile_id;
    
    RETURN ROUND(v_rating, 2);
END;
$$;


-- 3. get_freelancer_total_earnings - Sum all transactions for a freelancer's completed contracts
-- Returns the total earnings across all completed contracts
CREATE OR REPLACE FUNCTION job_market.get_freelancer_total_earnings(p_profile_id BIGINT)
    RETURNS NUMERIC
    LANGUAGE plpgsql
AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(t.amount), 0)
    INTO v_total
    FROM transactions t
    JOIN contracts c ON t.contract_id = c.id
    WHERE c.freelancer_id = p_profile_id 
      AND t.type = 'payment';
    
    RETURN ROUND(v_total, 2);
END;
$$;


-- 4. get_last_transaction_amount - Get the most recent transaction for a contract
-- Returns the amount of the most recent transaction
CREATE OR REPLACE FUNCTION job_market.get_last_transaction_amount(p_contract_id BIGINT)
    RETURNS NUMERIC
    LANGUAGE plpgsql
AS $$
DECLARE
    v_amount NUMERIC;
BEGIN
    SELECT amount
    INTO v_amount
    FROM transactions
    WHERE contract_id = p_contract_id
    ORDER BY created_at DESC
    LIMIT 1;
    
    RETURN COALESCE(v_amount, 0);
END;
$$;


-- 5. get_skill_match_count - Count how many required skills a freelancer has for a job
-- Returns count of skills that match between job requirements and freelancer's skills
CREATE OR REPLACE FUNCTION job_market.get_skill_match_count(
    p_job_id BIGINT,
    p_profile_id BIGINT
)
    RETURNS INTEGER
    LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(DISTINCT jrs.skill_id)
    INTO v_count
    FROM job_required_skills jrs
    WHERE jrs.job_id = p_job_id
      AND jrs.skill_id IN (
        SELECT skill_id FROM profile_skills WHERE profile_id = p_profile_id
      );
    
    RETURN COALESCE(v_count, 0);
END;
$$;


-- 6. is_freelancer_available - Check if a freelancer is currently available
-- Returns true if the freelancer is available (not all contract slots are full)
-- Returns false if unavailable or profile doesn't exist
CREATE OR REPLACE FUNCTION job_market.is_freelancer_available(p_profile_id BIGINT)
    RETURNS BOOLEAN
    LANGUAGE plpgsql
AS $$
DECLARE
    v_available BOOLEAN;
    v_max_concurrent INTEGER := 5;
    v_active_contracts INTEGER;
BEGIN
    -- Check if profile exists
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = p_profile_id) THEN
        RETURN FALSE;
    END IF;
    
    -- Count active contracts
    SELECT COUNT(*)
    INTO v_active_contracts
    FROM contracts
    WHERE freelancer_id = p_profile_id AND status = 'active';
    
    -- Available if active contracts < max concurrent contracts
    v_available := v_active_contracts < v_max_concurrent;
    
    RETURN v_available;
END;
$$;


-- 7. finalize_proposal_and_create_contract - Accept a proposal and create a contract
-- Creates a contract from a proposal, marks proposal as accepted, and updates job status to IN_PROGRESS
CREATE OR REPLACE PROCEDURE job_market.finalize_proposal_and_create_contract(p_proposal_id BIGINT)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_proposal_id BIGINT;
    v_job_id BIGINT;
    v_freelancer_id BIGINT;
    v_bid_amount DECIMAL(15, 2);
    v_status_id BIGINT;
    v_in_progress_status_id BIGINT;
BEGIN
    -- 1. Get proposal details
    SELECT id, job_id, freelancer_id, bid_amount
    INTO v_proposal_id, v_job_id, v_freelancer_id, v_bid_amount
    FROM proposals
    WHERE id = p_proposal_id;
    
    -- 2. Verify proposal exists
    IF v_proposal_id IS NULL THEN
        RAISE EXCEPTION 'Proposal with ID % does not exist.', p_proposal_id;
    END IF;
    
    -- 3. Check if proposal is not already accepted/rejected
    IF EXISTS (SELECT 1 FROM proposals WHERE id = p_proposal_id AND status != 'pending') THEN
        RAISE EXCEPTION 'Proposal with ID % is not in pending status.', p_proposal_id;
    END IF;
    
    -- 4. Create contract
    INSERT INTO contracts (
        job_id,
        client_id,
        freelancer_id,
        contract_value,
        status,
        created_at
    )
    VALUES (
        v_job_id,
        (SELECT client_id FROM jobs WHERE id = v_job_id),
        v_freelancer_id,
        v_bid_amount,
        'active',
        NOW()
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


-- 8. register_user - Extended user registration with role parameter (already exists, included for completeness)
-- This is already implemented in V5, but we ensure it exists
CREATE OR REPLACE PROCEDURE job_market.register_user(
    p_email VARCHAR(255),
    p_password_hash VARCHAR(255),
    p_role_id INTEGER,
    p_first_name VARCHAR(100),
    p_last_name VARCHAR(100),
    p_hourly_rate DECIMAL(10,2)
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_new_account_id BIGINT;
BEGIN
    INSERT INTO accounts (email, password_hash, role_id)
    VALUES (p_email, p_password_hash, p_role_id)
    RETURNING id INTO v_new_account_id;

    INSERT INTO profiles (account_id, first_name, last_name, hourly_rate)
    VALUES (v_new_account_id, p_first_name, p_last_name, p_hourly_rate);

    RAISE NOTICE 'User % successfully registered. Account ID: %', p_email, v_new_account_id;

EXCEPTION
    WHEN unique_violation THEN
        IF SQLERRM ILIKE '%email%' THEN
            RAISE EXCEPTION 'Account with email "%" already exists.', p_email;
        ELSE
            RAISE EXCEPTION 'DB unique violation (possible ID out of sync): %', SQLERRM;
        END IF;

    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error during user registration %. Details: %', p_email, SQLERRM;
END;
$$;
