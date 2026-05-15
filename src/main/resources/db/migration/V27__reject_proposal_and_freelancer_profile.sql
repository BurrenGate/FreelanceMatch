-- V27: Reject proposal functionality and freelancer profile view

-- 1. Procedure to reject a proposal (for clients)
CREATE OR REPLACE PROCEDURE job_market.reject_proposal(
    p_proposal_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_proposal_status VARCHAR(50);
BEGIN
    -- Check if proposal exists and get its status
    SELECT status INTO v_proposal_status
    FROM proposals
    WHERE id = p_proposal_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Proposal with ID % not found', p_proposal_id;
    END IF;

    -- Check if proposal is in pending status
    IF v_proposal_status != 'pending' THEN
        RAISE EXCEPTION 'Only pending proposals can be rejected. Current status: %', v_proposal_status;
    END IF;

    -- Update proposal status to rejected
    UPDATE proposals
    SET status = 'rejected'
    WHERE id = p_proposal_id;

    RAISE NOTICE 'Proposal % has been rejected', p_proposal_id;
END;
$$;

-- 2. Function to get freelancer profile with statistics
CREATE OR REPLACE FUNCTION job_market.get_freelancer_profile(
    p_freelancer_id BIGINT
)
RETURNS TABLE (
    profile_id BIGINT,
    account_id BIGINT,
    email VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    bio TEXT,
    hourly_rate DECIMAL(10,2),
    avatar_url VARCHAR(255),
    rating DECIMAL(3,2),
    total_earnings DECIMAL(15,2),
    completed_jobs INTEGER,
    active_jobs INTEGER,
    total_reviews INTEGER,
    is_available BOOLEAN,
    member_since TIMESTAMP,
    last_login TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS profile_id,
        p.account_id,
        a.email,
        p.first_name,
        p.last_name,
        p.bio,
        p.hourly_rate,
        p.avatar_url,
        COALESCE(job_market.get_freelancer_rating(p.id), 0.00) AS rating,
        COALESCE(job_market.get_freelancer_total_earnings(p.id), 0.00) AS total_earnings,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM contracts c 
             WHERE c.freelancer_id = p.id AND c.status = 'completed'),
            0
        ) AS completed_jobs,
        COALESCE(job_market.get_active_jobs_count(p.id), 0) AS active_jobs,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM reviews r 
             JOIN contracts c ON c.id = r.contract_id 
             WHERE c.freelancer_id = p.id),
            0
        ) AS total_reviews,
        COALESCE(job_market.is_freelancer_available(p.id), false) AS is_available,
        a.created_at AS member_since,
        a.last_login
    FROM profiles p
    JOIN accounts a ON a.id = p.account_id
    WHERE p.id = p_freelancer_id
      AND a.role_id = 2; -- freelancer role
END;
$$;

-- 3. Function to get freelancer skills
CREATE OR REPLACE FUNCTION job_market.get_freelancer_skills(
    p_freelancer_id BIGINT
)
RETURNS TABLE (
    skill_id INTEGER,
    skill_name VARCHAR(100),
    skill_category VARCHAR(100),
    skill_level VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id AS skill_id,
        s.name AS skill_name,
        s.category AS skill_category,
        ps.skill_level
    FROM profile_skills ps
    JOIN skills s ON s.id = ps.skill_id
    WHERE ps.profile_id = p_freelancer_id
    ORDER BY s.name;
END;
$$;

-- 4. Function to get freelancer recent reviews
CREATE OR REPLACE FUNCTION job_market.get_freelancer_reviews(
    p_freelancer_id BIGINT,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    review_id BIGINT,
    contract_id BIGINT,
    job_title VARCHAR(255),
    reviewer_name VARCHAR(201),
    rating INTEGER,
    comment TEXT,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id AS review_id,
        r.contract_id,
        j.title AS job_title,
        CONCAT(reviewer_profile.first_name, ' ', reviewer_profile.last_name) AS reviewer_name,
        r.rating,
        r.comment,
        t.created_at
    FROM reviews r
    JOIN contracts c ON c.id = r.contract_id
    JOIN jobs j ON j.id = c.job_id
    JOIN profiles reviewer_profile ON reviewer_profile.id = r.reviewer_id
    JOIN transactions t ON t.contract_id = c.id
    WHERE c.freelancer_id = p_freelancer_id
    ORDER BY t.created_at DESC
    LIMIT p_limit;
END;
$$;

COMMENT ON PROCEDURE job_market.reject_proposal IS 'Allows clients to reject a pending proposal';
COMMENT ON FUNCTION job_market.get_freelancer_profile IS 'Returns detailed freelancer profile with statistics';
COMMENT ON FUNCTION job_market.get_freelancer_skills IS 'Returns all skills of a freelancer';
COMMENT ON FUNCTION job_market.get_freelancer_reviews IS 'Returns recent reviews for a freelancer';
