-- V8: This script establishes the job_market schema, which contains functions, procedures, and triggers
-- for managing the core marketplace logic. This includes job and freelancer recommendations, proposal
-- submissions, contract lifecycle management, and automated notifications and audit trails.

CREATE SCHEMA IF NOT EXISTS job_market;

-- =============================================================================
-- SECTION 1: Freelancer and Client Statistics Functions
-- =============================================================================

-- Function to get the average rating for a freelancer.
-- It calculates the average from all reviews where the freelancer was not the reviewer.
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
COMMENT ON FUNCTION job_market.get_freelancer_rating(BIGINT)
IS 'Calculates the average rating for a freelancer based on reviews from clients.';

-- Function to get the total earnings for a freelancer from completed contracts.
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
COMMENT ON FUNCTION job_market.get_freelancer_total_earnings(BIGINT)
IS 'Calculates the total earnings for a freelancer from all completed and paid contracts.';

-- Function to count the number of active jobs for a client or freelancer.
CREATE OR REPLACE FUNCTION job_market.get_active_jobs_count(p_profile_id BIGINT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
    v_role_id INTEGER;
BEGIN
    SELECT role_id INTO v_role_id FROM accounts WHERE id = (SELECT account_id FROM profiles WHERE id = p_profile_id);

    IF v_role_id = 1 THEN -- Client
        SELECT COUNT(*) INTO v_count
        FROM jobs j
        JOIN job_statuses js ON js.id = j.status_id
        WHERE j.client_id = p_profile_id AND js.status_name IN ('OPEN', 'IN_PROGRESS');
    ELSIF v_role_id = 2 THEN -- Freelancer
        SELECT COUNT(*) INTO v_count
        FROM contracts c
        WHERE c.freelancer_id = p_profile_id AND c.status = 'active';
    ELSE
        v_count := 0;
    END IF;
    
    RETURN COALESCE(v_count, 0);
END;
$$;
COMMENT ON FUNCTION job_market.get_active_jobs_count(BIGINT)
IS 'Returns the number of active jobs for a client or active contracts for a freelancer.';


-- Function to check if a freelancer is available to take on new contracts.
-- Availability is based on a predefined limit of concurrent active contracts.
CREATE OR REPLACE FUNCTION job_market.is_freelancer_available(p_profile_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_max_concurrent INTEGER := 3; -- Maximum number of concurrent contracts
    v_active_contracts INTEGER;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM profiles WHERE id = p_profile_id) THEN
        RETURN FALSE;
    END IF;

    SELECT COUNT(*)
    INTO v_active_contracts
    FROM contracts
    WHERE freelancer_id = p_profile_id AND status = 'active';

    RETURN v_active_contracts < v_max_concurrent;
END;
$$;
COMMENT ON FUNCTION job_market.is_freelancer_available(BIGINT)
IS 'Checks if a freelancer has capacity for new contracts (less than 3 active).';

-- =============================================================================
-- SECTION 2: Job and Freelancer Matching Functions
-- =============================================================================

-- Function to recommend freelancers for a specific job based on skill match.
CREATE OR REPLACE FUNCTION job_market.get_recommended_freelancers(p_job_id BIGINT)
RETURNS TABLE (
    profile_id   BIGINT,
    full_name    VARCHAR(201),
    hourly_rate  DECIMAL(10,2),
    email        VARCHAR(255),
    match_pct    NUMERIC(5,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_required INT;
BEGIN
    SELECT COUNT(*) INTO v_total_required
    FROM job_required_skills
    WHERE job_id = p_job_id;

    IF v_total_required = 0 THEN
        RETURN;
    END IF;

    RETURN QUERY
    SELECT
        p.id,
        (p.first_name || ' ' || p.last_name)::VARCHAR(201),
        p.hourly_rate,
        a.email,
        ROUND((COUNT(ps.skill_id)::NUMERIC / v_total_required) * 100, 2) as match_pct
    FROM profiles p
    JOIN accounts a ON a.id = p.account_id
    JOIN profile_skills ps ON ps.profile_id = p.id
    JOIN job_required_skills jrs ON jrs.skill_id = ps.skill_id
    WHERE a.role_id = 2 AND jrs.job_id = p_job_id
    GROUP BY p.id, a.email
    HAVING (COUNT(ps.skill_id)::NUMERIC / v_total_required) * 100 >= 50;
END;
$$;
COMMENT ON FUNCTION job_market.get_recommended_freelancers(BIGINT)
IS 'Recommends freelancers for a job by calculating the percentage of matching skills.';

-- Function to count matching skills between a job and a freelancer profile.
CREATE OR REPLACE FUNCTION job_market.get_skill_match_count(p_job_id BIGINT, p_profile_id BIGINT)
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
COMMENT ON FUNCTION job_market.get_skill_match_count(BIGINT, BIGINT)
IS 'Counts the number of required job skills that a freelancer possesses.';

-- =============================================================================
-- SECTION 3: Proposal and Contract Lifecycle Procedures
-- =============================================================================

-- Procedure to submit a proposal for a job.
CREATE OR REPLACE PROCEDURE job_market.submit_proposal(
    p_job_id        BIGINT,
    p_freelancer_id BIGINT,
    p_bid_amount    DECIMAL(15,2),
    p_cover_letter  TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validation is handled by the `validate_proposal_submission` procedure.
    CALL job_market.validate_proposal_submission(p_job_id, p_freelancer_id, p_bid_amount);

    INSERT INTO proposals (job_id, freelancer_id, bid_amount, cover_letter, status)
    VALUES (p_job_id, p_freelancer_id, p_bid_amount, p_cover_letter, 'pending');
END;
$$;
COMMENT ON PROCEDURE job_market.submit_proposal(BIGINT, BIGINT, DECIMAL, TEXT)
IS 'Submits a freelancer''s proposal for a job after validation.';

-- Procedure to reject a pending proposal.
CREATE OR REPLACE PROCEDURE job_market.reject_proposal(p_proposal_id BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_proposal_status VARCHAR(50);
BEGIN
    SELECT status INTO v_proposal_status
    FROM proposals
    WHERE id = p_proposal_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Proposal with ID % not found', p_proposal_id;
    END IF;

    IF v_proposal_status != 'pending' THEN
        RAISE EXCEPTION 'Only pending proposals can be rejected. Current status: %', v_proposal_status;
    END IF;

    UPDATE proposals
    SET status = 'rejected'
    WHERE id = p_proposal_id;

    RAISE NOTICE 'Proposal % has been rejected', p_proposal_id;
END;
$$;
COMMENT ON PROCEDURE job_market.reject_proposal(BIGINT)
IS 'Allows a client to reject a pending proposal for their job.';

-- Procedure to finalize a proposal, create a contract, and update job/proposal statuses.
CREATE OR REPLACE PROCEDURE job_market.finalize_proposal_and_create_contract(p_proposal_id BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id BIGINT;
    v_freelancer_id BIGINT;
    v_bid_amount DECIMAL(15, 2);
BEGIN
    -- Validation is handled by the `validate_contract_creation` procedure.
    SELECT job_id, freelancer_id, bid_amount
    INTO v_job_id, v_freelancer_id, v_bid_amount
    FROM proposals
    WHERE id = p_proposal_id;

    CALL job_market.validate_contract_creation(p_proposal_id, v_job_id, v_freelancer_id);

    -- Create the contract.
    INSERT INTO contracts (job_id, freelancer_id, total_amount, status)
    VALUES (v_job_id, v_freelancer_id, v_bid_amount, 'active');

    -- Update proposal statuses.
    UPDATE proposals SET status = 'accepted' WHERE id = p_proposal_id;
    UPDATE proposals SET status = 'rejected' WHERE job_id = v_job_id AND id != p_proposal_id AND status = 'pending';

    -- Update job status to IN_PROGRESS.
    UPDATE jobs SET status_id = (SELECT id FROM job_statuses WHERE status_name = 'IN_PROGRESS')
    WHERE id = v_job_id;

    RAISE NOTICE 'Proposal % finalized. Contract created and job status updated to IN_PROGRESS', p_proposal_id;
END;
$$;
COMMENT ON PROCEDURE job_market.finalize_proposal_and_create_contract(BIGINT)
IS 'Accepts a proposal, creates a contract, rejects other proposals, and sets the job to IN_PROGRESS.';

-- Procedure to complete a job, process payment, and leave a review.
CREATE OR REPLACE PROCEDURE job_market.complete_job_and_rate(
    p_contract_id BIGINT,
    p_rating      NUMERIC,
    p_feedback    TEXT,
    p_reviewer_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_id          BIGINT;
    v_total_amount    DECIMAL(15,2);
BEGIN
    -- Validation is handled by dedicated validation procedures.
    CALL job_market.validate_contract_completion(p_contract_id);
    CALL job_market.validate_review_submission(p_contract_id, p_reviewer_id, ROUND(p_rating)::INTEGER);

    SELECT job_id, total_amount INTO v_job_id, v_total_amount
    FROM contracts WHERE id = p_contract_id;

    -- Update statuses
    UPDATE contracts SET status = 'completed' WHERE id = p_contract_id;
    UPDATE jobs SET status_id = (SELECT id FROM job_statuses WHERE status_name = 'COMPLETED') WHERE id = v_job_id;

    -- Process payment
    INSERT INTO transactions (contract_id, amount, type)
    VALUES (p_contract_id, v_total_amount, 'payment');

    -- Submit review
    INSERT INTO reviews (contract_id, reviewer_id, rating, comment)
    VALUES (p_contract_id, p_reviewer_id, ROUND(p_rating)::INTEGER, p_feedback);
END;
$$;
COMMENT ON PROCEDURE job_market.complete_job_and_rate(BIGINT, NUMERIC, TEXT, BIGINT)
IS 'Completes a contract, processes the final payment, and submits a review.';

-- Procedure to safely delete a job and all its related data.
CREATE OR REPLACE PROCEDURE job_market.delete_job(p_job_id BIGINT)
LANGUAGE plpgsql
AS $$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM jobs WHERE id = p_job_id) THEN
        RAISE EXCEPTION 'Job with ID % does not exist', p_job_id;
    END IF;

    DELETE FROM reviews WHERE contract_id IN (SELECT id FROM contracts WHERE job_id = p_job_id);
    DELETE FROM transactions WHERE contract_id IN (SELECT id FROM contracts WHERE job_id = p_job_id);
    DELETE FROM contracts WHERE job_id = p_job_id;
    DELETE FROM proposals WHERE job_id = p_job_id;
    DELETE FROM job_required_skills WHERE job_id = p_job_id;
    DELETE FROM jobs WHERE id = p_job_id;

    RAISE NOTICE 'Job % and all related data deleted successfully', p_job_id;
END;
$$;
COMMENT ON PROCEDURE job_market.delete_job(BIGINT)
IS 'Safely deletes a job and all its associated data (proposals, contracts, etc.).';

-- =============================================================================
-- SECTION 4: Data Retrieval and Browsing Functions
-- =============================================================================

-- Function to get all open jobs with a count of required skills.
CREATE OR REPLACE FUNCTION job_market.get_open_jobs_with_details()
RETURNS TABLE (
    id BIGINT,
    client_id BIGINT,
    title VARCHAR(255),
    description TEXT,
    budget_type VARCHAR(50),
    min_budget DECIMAL(15,2),
    max_budget DECIMAL(15,2),
    status_name VARCHAR(50),
    created_at TIMESTAMP,
    required_skills_count INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        j.id, j.client_id, j.title, j.description, j.budget_type,
        j.min_budget, j.max_budget, js.status_name, j.created_at,
        COALESCE((SELECT COUNT(*)::INTEGER FROM job_required_skills jrs WHERE jrs.job_id = j.id), 0)
    FROM jobs j
    JOIN job_statuses js ON js.id = j.status_id
    WHERE js.status_name = 'OPEN'
    ORDER BY j.created_at DESC;
END;
$$;
COMMENT ON FUNCTION job_market.get_open_jobs_with_details()
IS 'Retrieves all open jobs, including a count of required skills for each.';

-- Function to get the skills required for a specific job.
CREATE OR REPLACE FUNCTION job_market.get_job_skills(p_job_id BIGINT)
RETURNS TABLE (
    skill_id INTEGER,
    skill_name VARCHAR(100),
    skill_category VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.name, s.category
    FROM job_required_skills jrs
    JOIN skills s ON s.id = jrs.skill_id
    WHERE jrs.job_id = p_job_id
    ORDER BY s.name;
END;
$$;
COMMENT ON FUNCTION job_market.get_job_skills(BIGINT)
IS 'Retrieves the list of skills required for a given job.';

-- Function to get proposals for a job, including details about the freelancers.
CREATE OR REPLACE FUNCTION job_market.get_proposals_with_freelancer_details(p_job_id BIGINT)
RETURNS TABLE (
    proposal_id BIGINT,
    job_id BIGINT,
    freelancer_id BIGINT,
    bid_amount DECIMAL(15,2),
    delivery_days INTEGER,
    cover_letter TEXT,
    status VARCHAR(50),
    created_at TIMESTAMP,
    freelancer_name TEXT,
    freelancer_email VARCHAR(255),
    freelancer_hourly_rate DECIMAL(10,2),
    freelancer_avatar_url VARCHAR(1000),
    freelancer_rating NUMERIC,
    freelancer_completed_jobs INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        pr.id, pr.job_id, pr.freelancer_id, pr.bid_amount, pr.delivery_days, pr.cover_letter,
        pr.status, pr.created_at,
        (p.first_name || ' ' || p.last_name)::TEXT,
        a.email, p.hourly_rate, p.avatar_url,
        job_market.get_freelancer_rating(p.id),
        (SELECT COUNT(*)::INTEGER FROM contracts c WHERE c.freelancer_id = p.id AND c.status = 'completed')
    FROM proposals pr
    JOIN profiles p ON p.id = pr.freelancer_id
    JOIN accounts a ON a.id = p.account_id
    WHERE pr.job_id = p_job_id
    ORDER BY pr.created_at DESC;
END;
$$;
COMMENT ON FUNCTION job_market.get_proposals_with_freelancer_details(BIGINT)
IS 'Retrieves all proposals for a job, enriched with details about each freelancer.';

-- =============================================================================
-- SECTION 5: Detailed Profile and Dashboard Functions
-- =============================================================================

-- Function to get a comprehensive freelancer profile with statistics.
CREATE OR REPLACE FUNCTION job_market.get_freelancer_profile(p_freelancer_id BIGINT)
RETURNS TABLE (
    profile_id BIGINT, account_id BIGINT, email VARCHAR(255), first_name VARCHAR(100),
    last_name VARCHAR(100), full_name TEXT, bio TEXT, hourly_rate DECIMAL(10,2),
    avatar_url VARCHAR(1000), rating NUMERIC, total_earnings NUMERIC, completed_jobs INTEGER,
    active_jobs INTEGER, total_reviews INTEGER, is_available BOOLEAN, member_since TIMESTAMP,
    last_login TIMESTAMP, account_status VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id, p.account_id, a.email, p.first_name, p.last_name,
        (p.first_name || ' ' || p.last_name)::TEXT, p.bio, p.hourly_rate, p.avatar_url,
        job_market.get_freelancer_rating(p.id),
        job_market.get_freelancer_total_earnings(p.id),
        (SELECT COUNT(*)::INTEGER FROM contracts c WHERE c.freelancer_id = p.id AND c.status = 'completed'),
        job_market.get_active_jobs_count(p.id),
        (SELECT COUNT(*)::INTEGER FROM reviews r JOIN contracts c ON c.id = r.contract_id WHERE c.freelancer_id = p.id),
        job_market.is_freelancer_available(p.id),
        a.created_at, a.last_login, a.status
    FROM profiles p
    JOIN accounts a ON a.id = p.account_id
    WHERE p.id = p_freelancer_id AND a.role_id = 2;
END;
$$;
COMMENT ON FUNCTION job_market.get_freelancer_profile(BIGINT)
IS 'Retrieves a detailed profile for a freelancer, including performance statistics.';

-- Function to get a comprehensive client profile with statistics.
CREATE OR REPLACE FUNCTION job_market.get_client_profile(p_client_id BIGINT)
RETURNS TABLE (
    profile_id BIGINT, account_id BIGINT, email VARCHAR(255), first_name VARCHAR(100),
    last_name VARCHAR(100), bio TEXT, avatar_url VARCHAR(1000), total_spent DECIMAL(15,2),
    posted_jobs INTEGER, active_jobs INTEGER, completed_jobs INTEGER, total_reviews_given INTEGER,
    average_rating_given DECIMAL(3,2), member_since TIMESTAMP, last_login TIMESTAMP, account_status VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id, p.account_id, a.email, p.first_name, p.last_name, p.bio, p.avatar_url,
        (SELECT COALESCE(SUM(t.amount), 0.00) FROM transactions t JOIN contracts c ON c.id = t.contract_id JOIN jobs j ON j.id = c.job_id WHERE j.client_id = p.id AND t.type = 'payment'),
        (SELECT COUNT(*)::INTEGER FROM jobs j WHERE j.client_id = p.id),
        job_market.get_active_jobs_count(p.id),
        (SELECT COUNT(*)::INTEGER FROM contracts c JOIN jobs j ON j.id = c.job_id WHERE j.client_id = p.id AND c.status = 'completed'),
        (SELECT COUNT(*)::INTEGER FROM reviews r WHERE r.reviewer_id = p.id),
        (SELECT COALESCE(AVG(r.rating), 0.00)::DECIMAL(3,2) FROM reviews r WHERE r.reviewer_id = p.id),
        a.created_at, a.last_login, a.status
    FROM profiles p
    JOIN accounts a ON a.id = p.account_id
    WHERE p.id = p_client_id AND a.role_id = 1;
END;
$$;
COMMENT ON FUNCTION job_market.get_client_profile(BIGINT)
IS 'Retrieves a detailed profile for a client, including spending and job statistics.';

-- Function to get a freelancer's dashboard summary.
CREATE OR REPLACE FUNCTION job_market.get_freelancer_dashboard(p_freelancer_id BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_recent_activity JSONB;
    v_result JSONB;
BEGIN
    -- Aggregate recent activity (proposals and transactions).
    WITH activity AS (
        SELECT 'PROPOSAL' AS "activityType", j.title, p.status, p.bid_amount AS "amount", p.created_at AS "date"
        FROM proposals p JOIN jobs j ON p.job_id = j.id
        WHERE p.freelancer_id = p_freelancer_id
        UNION ALL
        SELECT 'TRANSACTION' AS "activityType", j.title, t.type AS "status", t.amount, t.created_at AS "date"
        FROM transactions t JOIN contracts c ON t.contract_id = c.id JOIN jobs j ON c.job_id = j.id
        WHERE c.freelancer_id = p_freelancer_id
        ORDER BY "date" DESC
        LIMIT 10
    )
    SELECT COALESCE(jsonb_agg(row_to_json(activity)), '[]'::jsonb) INTO v_recent_activity FROM activity;

    -- Build the final JSON object with all dashboard metrics.
    SELECT jsonb_build_object(
        'totalEarnings', job_market.get_freelancer_total_earnings(p_freelancer_id),
        'activeContracts', (SELECT COUNT(*) FROM contracts WHERE freelancer_id = p_freelancer_id AND status = 'active'),
        'completedJobs', (SELECT COUNT(*) FROM contracts WHERE freelancer_id = p_freelancer_id AND status = 'completed'),
        'pendingProposals', (SELECT COUNT(*) FROM proposals WHERE freelancer_id = p_freelancer_id AND status = 'pending'),
        'averageRating', job_market.get_freelancer_rating(p_freelancer_id),
        'jobSuccessScore', ROUND((job_market.get_freelancer_rating(p_freelancer_id) / 5.0) * 100, 0),
        'recentActivity', v_recent_activity
    ) INTO v_result;

    RETURN v_result;
END;
$$;
COMMENT ON FUNCTION job_market.get_freelancer_dashboard(BIGINT)
IS 'Generates a JSONB summary for the freelancer dashboard, including earnings, job stats, and recent activity.';

-- =============================================================================
-- SECTION 6: Validation Procedures
-- =============================================================================

-- Procedure to validate the creation of a new job.
CREATE OR REPLACE PROCEDURE job_market.validate_job_creation(
    p_client_id BIGINT, p_title VARCHAR(255), p_application_deadline DATE,
    p_start_date DATE, p_end_date DATE
) LANGUAGE plpgsql AS $$
BEGIN
    IF p_application_deadline < CURRENT_DATE THEN RAISE EXCEPTION 'Application deadline cannot be in the past.'; END IF;
    IF p_start_date IS NOT NULL AND p_start_date <= p_application_deadline THEN RAISE EXCEPTION 'Job start date must be after application deadline.'; END IF;
    IF p_end_date IS NOT NULL AND p_start_date IS NOT NULL AND p_end_date <= p_start_date THEN RAISE EXCEPTION 'Job end date must be after start date.'; END IF;
    IF EXISTS (SELECT 1 FROM jobs WHERE client_id = p_client_id AND title = p_title AND status_id IN (1, 2) AND is_cancelled = FALSE) THEN RAISE EXCEPTION 'You already have an active job with the same title.'; END IF;
END;
$$;
COMMENT ON PROCEDURE job_market.validate_job_creation(BIGINT, VARCHAR, DATE, DATE, DATE) IS 'Enforces business rules before a job is created.';

-- Procedure to validate the submission of a proposal.
CREATE OR REPLACE PROCEDURE job_market.validate_proposal_submission(
    p_job_id BIGINT, p_freelancer_id BIGINT, p_bid_amount DECIMAL(15,2)
) LANGUAGE plpgsql AS $$
DECLARE
    v_job_status_id INTEGER; v_job_client_id BIGINT; v_application_deadline DATE;
    v_freelancer_role_id INTEGER;
BEGIN
    SELECT status_id, client_id, application_deadline INTO v_job_status_id, v_job_client_id, v_application_deadline FROM jobs WHERE id = p_job_id;
    IF v_job_status_id IS NULL THEN RAISE EXCEPTION 'Job % not found', p_job_id; END IF;
    IF v_job_status_id != 1 THEN RAISE EXCEPTION 'Job is not open for proposals.'; END IF;
    IF v_application_deadline IS NOT NULL AND v_application_deadline < CURRENT_DATE THEN RAISE EXCEPTION 'Application deadline has passed.'; END IF;
    IF v_job_client_id = p_freelancer_id THEN RAISE EXCEPTION 'You cannot submit a proposal to your own job.'; END IF;
    SELECT a.role_id INTO v_freelancer_role_id FROM accounts a JOIN profiles p ON a.id = p.account_id WHERE p.id = p_freelancer_id;
    IF v_freelancer_role_id != 2 THEN RAISE EXCEPTION 'Only freelancers can submit proposals.'; END IF;
    IF NOT job_market.is_freelancer_available(p_freelancer_id) THEN RAISE EXCEPTION 'You have reached the maximum number of active contracts.'; END IF;
    IF p_bid_amount <= 0 THEN RAISE EXCEPTION 'Bid amount must be positive.'; END IF;
    IF EXISTS (SELECT 1 FROM proposals WHERE job_id = p_job_id AND freelancer_id = p_freelancer_id AND status != 'rejected') THEN RAISE EXCEPTION 'You have already submitted a proposal to this job.'; END IF;
END;
$$;
COMMENT ON PROCEDURE job_market.validate_proposal_submission(BIGINT, BIGINT, DECIMAL) IS 'Enforces business rules before a proposal is submitted.';

-- Procedure to validate the creation of a contract from a proposal.
CREATE OR REPLACE PROCEDURE job_market.validate_contract_creation(
    p_proposal_id BIGINT, p_job_id BIGINT, p_freelancer_id BIGINT
) LANGUAGE plpgsql AS $$
DECLARE
    v_job_status_id INTEGER; v_proposal_status VARCHAR(50);
BEGIN
    SELECT status_id INTO v_job_status_id FROM jobs WHERE id = p_job_id;
    IF v_job_status_id != 1 THEN RAISE EXCEPTION 'Job must be OPEN to create a contract.'; END IF;
    SELECT status INTO v_proposal_status FROM proposals WHERE id = p_proposal_id;
    IF v_proposal_status != 'pending' THEN RAISE EXCEPTION 'Proposal must be PENDING to create a contract.'; END IF;
    IF NOT job_market.is_freelancer_available(p_freelancer_id) THEN RAISE EXCEPTION 'Freelancer has reached the maximum number of active contracts.'; END IF;
END;
$$;
COMMENT ON PROCEDURE job_market.validate_contract_creation(BIGINT, BIGINT, BIGINT) IS 'Enforces business rules before a contract is created.';

-- Procedure to validate the completion of a contract.
CREATE OR REPLACE PROCEDURE job_market.validate_contract_completion(p_contract_id BIGINT)
LANGUAGE plpgsql AS $$
DECLARE
    v_contract_status VARCHAR(50);
BEGIN
    SELECT status INTO v_contract_status FROM contracts WHERE id = p_contract_id;
    IF v_contract_status != 'active' THEN RAISE EXCEPTION 'Contract must be ACTIVE to be completed.'; END IF;
END;
$$;
COMMENT ON PROCEDURE job_market.validate_contract_completion(BIGINT) IS 'Enforces business rules before a contract is completed.';

-- Procedure to validate the submission of a review.
CREATE OR REPLACE PROCEDURE job_market.validate_review_submission(
    p_contract_id BIGINT, p_reviewer_id BIGINT, p_rating INTEGER
) LANGUAGE plpgsql AS $$
DECLARE
    v_contract_status VARCHAR(50);
BEGIN
    IF p_rating NOT BETWEEN 1 AND 5 THEN RAISE EXCEPTION 'Rating must be between 1 and 5.'; END IF;
    SELECT status INTO v_contract_status FROM contracts WHERE id = p_contract_id;
    IF v_contract_status IS NULL THEN RAISE EXCEPTION 'Contract % not found.', p_contract_id; END IF;
    IF v_contract_status != 'completed' THEN RAISE EXCEPTION 'Can only review COMPLETED contracts.'; END IF;
    IF EXISTS (SELECT 1 FROM reviews WHERE contract_id = p_contract_id AND reviewer_id = p_reviewer_id) THEN RAISE EXCEPTION 'You have already reviewed this contract.'; END IF;
END;
$$;
COMMENT ON PROCEDURE job_market.validate_review_submission(BIGINT, BIGINT, INTEGER) IS 'Enforces business rules before a review is submitted.';

-- =============================================================================
-- SECTION 7: Notification and Audit Trail Utilities and Triggers
-- =============================================================================

-- Utility function to create a notification.
CREATE OR REPLACE FUNCTION job_market.create_notification(
    p_account_id BIGINT, p_notification_type VARCHAR(100), p_title VARCHAR(255),
    p_message TEXT, p_related_entity_type VARCHAR(100), p_related_entity_id BIGINT
) RETURNS BIGINT LANGUAGE plpgsql AS $$
DECLARE
    v_notification_id BIGINT;
BEGIN
    INSERT INTO notifications (account_id, notification_type, title, message, related_entity_type, related_entity_id)
    VALUES (p_account_id, p_notification_type, p_title, p_message, p_related_entity_type, p_related_entity_id)
    RETURNING id INTO v_notification_id;
    RETURN v_notification_id;
END;
$$;
COMMENT ON FUNCTION job_market.create_notification(BIGINT, VARCHAR, VARCHAR, TEXT, VARCHAR, BIGINT) IS 'Creates and inserts a new user notification.';

-- Utility function to create an audit log entry.
CREATE OR REPLACE FUNCTION job_market.create_audit_log(
    p_entity_type VARCHAR(100), p_entity_id BIGINT, p_action VARCHAR(50), p_changed_by BIGINT,
    p_old_value JSONB, p_new_value JSONB, p_change_summary TEXT
) RETURNS BIGINT LANGUAGE plpgsql AS $$
DECLARE
    v_audit_id BIGINT;
BEGIN
    INSERT INTO audit_log (entity_type, entity_id, action, changed_by, old_value, new_value, change_summary)
    VALUES (p_entity_type, p_entity_id, p_action, p_changed_by, p_old_value, p_new_value, p_change_summary)
    RETURNING id INTO v_audit_id;
    RETURN v_audit_id;
END;
$$;
COMMENT ON FUNCTION job_market.create_audit_log(VARCHAR, BIGINT, VARCHAR, BIGINT, JSONB, JSONB, TEXT) IS 'Creates and inserts a new audit log entry.';

-- Trigger to notify client upon new proposal submission.
CREATE OR REPLACE FUNCTION job_market.trg_fn_proposal_created_notify()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_client_account_id BIGINT; v_freelancer_name TEXT; v_job_title VARCHAR(255);
BEGIN
    SELECT j.client_id, j.title INTO v_client_account_id, v_job_title FROM jobs j WHERE j.id = NEW.job_id;
    SELECT p.first_name || ' ' || p.last_name INTO v_freelancer_name FROM profiles p WHERE p.id = NEW.freelancer_id;
    SELECT account_id INTO v_client_account_id FROM profiles WHERE id = v_client_account_id;
    PERFORM job_market.create_notification(v_client_account_id, 'PROPOSAL_RECEIVED', 'New Proposal Received',
        v_freelancer_name || ' submitted a proposal for job "' || v_job_title || '".', 'PROPOSAL', NEW.id);
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_proposal_created_notify ON proposals;
CREATE TRIGGER trg_proposal_created_notify AFTER INSERT ON proposals FOR EACH ROW EXECUTE FUNCTION job_market.trg_fn_proposal_created_notify();
COMMENT ON TRIGGER trg_proposal_created_notify ON proposals IS 'Notifies the client when a new proposal is submitted for their job.';

-- Trigger to notify freelancer and audit when a contract is created.
CREATE OR REPLACE FUNCTION job_market.trg_fn_contract_created_notify()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_freelancer_account_id BIGINT; v_client_name TEXT; v_job_title VARCHAR(255);
BEGIN
    SELECT account_id INTO v_freelancer_account_id FROM profiles WHERE id = NEW.freelancer_id;
    SELECT j.title, p.first_name || ' ' || p.last_name INTO v_job_title, v_client_name
    FROM jobs j JOIN profiles p ON p.id = j.client_id WHERE j.id = NEW.job_id;
    PERFORM job_market.create_notification(v_freelancer_account_id, 'CONTRACT_ACCEPTED', 'Contract Accepted',
        'Your proposal for job "' || v_job_title || '" was accepted by ' || v_client_name || '.', 'CONTRACT', NEW.id);
    PERFORM job_market.create_audit_log('CONTRACT', NEW.id, 'CREATE', NULL, NULL, ROW_TO_JSON(NEW)::jsonb, 'Contract created: ' || v_job_title);
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_contract_created_notify ON contracts;
CREATE TRIGGER trg_contract_created_notify AFTER INSERT ON contracts FOR EACH ROW EXECUTE FUNCTION job_market.trg_fn_contract_created_notify();
COMMENT ON TRIGGER trg_contract_created_notify ON contracts IS 'Notifies the freelancer and creates an audit log when a contract is created.';

-- Trigger to notify both parties and audit when a contract is completed.
CREATE OR REPLACE FUNCTION job_market.trg_fn_contract_completed_notify()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_freelancer_account_id BIGINT; v_client_account_id BIGINT; v_job_title VARCHAR(255);
BEGIN
    IF OLD.status = 'active' AND NEW.status = 'completed' THEN
        SELECT account_id INTO v_freelancer_account_id FROM profiles WHERE id = NEW.freelancer_id;
        SELECT account_id INTO v_client_account_id FROM profiles p JOIN jobs j ON p.id = j.client_id WHERE j.id = NEW.job_id;
        SELECT title INTO v_job_title FROM jobs WHERE id = NEW.job_id;
        PERFORM job_market.create_notification(v_freelancer_account_id, 'CONTRACT_COMPLETED', 'Contract Completed',
            'Contract for "' || v_job_title || '" is complete. Payment of $' || NEW.total_amount || ' has been processed.', 'CONTRACT', NEW.id);
        PERFORM job_market.create_notification(v_client_account_id, 'CONTRACT_COMPLETED', 'Contract Completed',
            'You have successfully completed the contract for "' || v_job_title || '".', 'CONTRACT', NEW.id);
        PERFORM job_market.create_audit_log('CONTRACT', NEW.id, 'UPDATE', NULL, ROW_TO_JSON(OLD)::jsonb, ROW_TO_JSON(NEW)::jsonb, 'Contract completed.');
    END IF;
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_contract_completed_notify ON contracts;
CREATE TRIGGER trg_contract_completed_notify AFTER UPDATE OF status ON contracts FOR EACH ROW EXECUTE FUNCTION job_market.trg_fn_contract_completed_notify();
COMMENT ON TRIGGER trg_contract_completed_notify ON contracts IS 'Notifies both parties and audits when a contract status changes to completed.';

-- Trigger to prevent a freelancer from reviewing their own work.
CREATE OR REPLACE FUNCTION job_market.trg_fn_prevent_self_review()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.reviewer_id = (SELECT freelancer_id FROM contracts WHERE id = NEW.contract_id) THEN
        RAISE EXCEPTION 'A freelancer cannot review their own work on a contract.';
    END IF;
    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trg_prevent_self_review ON reviews;
CREATE TRIGGER trg_prevent_self_review BEFORE INSERT ON reviews FOR EACH ROW EXECUTE FUNCTION job_market.trg_fn_prevent_self_review();
COMMENT ON TRIGGER trg_prevent_self_review ON reviews IS 'Prevents a freelancer from submitting a review on a contract they worked on.';
