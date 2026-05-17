-- V29: Fix get_freelancer_reviews function and improve freelancer profile

-- 1. Drop and recreate get_freelancer_reviews function with correct return type
DROP FUNCTION IF EXISTS job_market.get_freelancer_reviews(BIGINT, INTEGER);

CREATE FUNCTION job_market.get_freelancer_reviews(
    p_freelancer_id BIGINT,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    review_id BIGINT,
    contract_id BIGINT,
    job_title VARCHAR(255),
    reviewer_name TEXT,
    rating INTEGER,
    comment TEXT,
    review_date TIMESTAMP
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
        c.created_at AS review_date
    FROM reviews r
    JOIN contracts c ON c.id = r.contract_id
    JOIN jobs j ON j.id = c.job_id
    JOIN profiles reviewer_profile ON reviewer_profile.id = r.reviewer_id
    WHERE c.freelancer_id = p_freelancer_id
    ORDER BY c.created_at DESC
    LIMIT p_limit;
END;
$$;

-- 2. Add created_at column to contracts table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'contracts' AND column_name = 'created_at'
    ) THEN
        ALTER TABLE contracts ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
        
        -- Update existing records with a default timestamp
        UPDATE contracts SET created_at = NOW() WHERE created_at IS NULL;
        
        RAISE NOTICE 'Added created_at column to contracts table';
    END IF;
END $$;

-- 3. Improve get_freelancer_profile to return more complete data
DROP FUNCTION IF EXISTS job_market.get_freelancer_profile(BIGINT);

CREATE FUNCTION job_market.get_freelancer_profile(
    p_freelancer_id BIGINT
)
RETURNS TABLE (
    profile_id BIGINT,
    account_id BIGINT,
    email VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name TEXT,
    bio TEXT,
    hourly_rate DECIMAL(10,2),
    avatar_url VARCHAR(255),
    rating NUMERIC,
    total_earnings NUMERIC,
    completed_jobs INTEGER,
    active_jobs INTEGER,
    total_reviews INTEGER,
    is_available BOOLEAN,
    member_since TIMESTAMP,
    last_login TIMESTAMP,
    account_status VARCHAR(50)
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
        CONCAT(p.first_name, ' ', p.last_name) AS full_name,
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
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM contracts c 
             WHERE c.freelancer_id = p.id AND c.status = 'active'),
            0
        ) AS active_jobs,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM reviews r 
             JOIN contracts c ON c.id = r.contract_id 
             WHERE c.freelancer_id = p.id),
            0
        ) AS total_reviews,
        COALESCE(job_market.is_freelancer_available(p.id), false) AS is_available,
        a.created_at AS member_since,
        a.last_login,
        a.status AS account_status
    FROM profiles p
    JOIN accounts a ON a.id = p.account_id
    WHERE p.id = p_freelancer_id
      AND a.role_id = 2; -- freelancer role
END;
$$;

COMMENT ON FUNCTION job_market.get_freelancer_reviews IS 'Returns recent reviews for a freelancer (fixed to not depend on transactions)';
COMMENT ON FUNCTION job_market.get_freelancer_profile IS 'Returns detailed freelancer profile with complete statistics and personal information';


-- 4. Function to get proposals with freelancer details (for clients viewing proposals)
CREATE OR REPLACE FUNCTION job_market.get_proposals_with_freelancer_details(
    p_job_id BIGINT
)
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
    freelancer_avatar_url VARCHAR(255),
    freelancer_rating NUMERIC,
    freelancer_completed_jobs INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        pr.id AS proposal_id,
        pr.job_id,
        pr.freelancer_id,
        pr.bid_amount,
        pr.delivery_days,
        pr.cover_letter,
        pr.status,
        pr.created_at,
        CONCAT(p.first_name, ' ', p.last_name) AS freelancer_name,
        a.email AS freelancer_email,
        p.hourly_rate AS freelancer_hourly_rate,
        p.avatar_url AS freelancer_avatar_url,
        COALESCE(job_market.get_freelancer_rating(p.id), 0.00) AS freelancer_rating,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM contracts c 
             WHERE c.freelancer_id = p.id AND c.status = 'completed'),
            0
        ) AS freelancer_completed_jobs
    FROM proposals pr
    JOIN profiles p ON p.id = pr.freelancer_id
    JOIN accounts a ON a.id = p.account_id
    WHERE pr.job_id = p_job_id
    ORDER BY pr.created_at DESC;
END;
$$;

COMMENT ON FUNCTION job_market.get_proposals_with_freelancer_details IS 'Returns proposals for a job with detailed freelancer information';
