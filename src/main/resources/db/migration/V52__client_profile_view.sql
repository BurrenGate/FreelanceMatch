-- V52: Client profile view with statistics

-- Function to get client profile with statistics
CREATE OR REPLACE FUNCTION job_market.get_client_profile(
    p_client_id BIGINT
)
RETURNS TABLE (
    profile_id BIGINT,
    account_id BIGINT,
    email VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    bio TEXT,
    avatar_url VARCHAR(500),
    total_spent DECIMAL(15,2),
    posted_jobs INTEGER,
    active_jobs INTEGER,
    completed_jobs INTEGER,
    total_reviews_given INTEGER,
    average_rating_given DECIMAL(3,2),
    member_since TIMESTAMP,
    last_login TIMESTAMP,
    account_status VARCHAR(20)
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
        p.avatar_url,
        COALESCE(
            (SELECT SUM(t.amount) 
             FROM transactions t 
             JOIN contracts c ON c.id = t.contract_id 
             JOIN jobs j ON j.id = c.job_id 
             WHERE j.client_id = p.id AND t.transaction_type = 'payment'),
            0.00
        ) AS total_spent,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM jobs j 
             WHERE j.client_id = p.id),
            0
        ) AS posted_jobs,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM jobs j 
             WHERE j.client_id = p.id AND j.status = 'open'),
            0
        ) AS active_jobs,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM contracts c 
             JOIN jobs j ON j.id = c.job_id 
             WHERE j.client_id = p.id AND c.status = 'completed'),
            0
        ) AS completed_jobs,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM reviews r 
             WHERE r.reviewer_id = p.id),
            0
        ) AS total_reviews_given,
        COALESCE(
            (SELECT AVG(r.rating)::DECIMAL(3,2) 
             FROM reviews r 
             WHERE r.reviewer_id = p.id),
            0.00
        ) AS average_rating_given,
        a.created_at AS member_since,
        a.last_login,
        a.status AS account_status
    FROM profiles p
    JOIN accounts a ON a.id = p.account_id
    WHERE p.id = p_client_id
      AND a.role_id = 1; -- client role
END;
$$;

-- Function to get client's posted jobs
CREATE OR REPLACE FUNCTION job_market.get_client_jobs(
    p_client_id BIGINT,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    job_id BIGINT,
    title VARCHAR(255),
    description TEXT,
    budget DECIMAL(10,2),
    status VARCHAR(50),
    proposals_count INTEGER,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        j.id AS job_id,
        j.title,
        j.description,
        j.budget,
        j.status,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM proposals pr 
             WHERE pr.job_id = j.id),
            0
        ) AS proposals_count,
        j.created_at
    FROM jobs j
    WHERE j.client_id = p_client_id
    ORDER BY j.created_at DESC
    LIMIT p_limit;
END;
$$;

-- Function to get reviews given by client
CREATE OR REPLACE FUNCTION job_market.get_client_reviews_given(
    p_client_id BIGINT,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    review_id BIGINT,
    contract_id BIGINT,
    job_title VARCHAR(255),
    freelancer_name VARCHAR(201),
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
        CONCAT(freelancer_profile.first_name, ' ', freelancer_profile.last_name) AS freelancer_name,
        r.rating,
        r.comment,
        r.created_at
    FROM reviews r
    JOIN contracts c ON c.id = r.contract_id
    JOIN jobs j ON j.id = c.job_id
    JOIN profiles freelancer_profile ON freelancer_profile.id = c.freelancer_id
    WHERE r.reviewer_id = p_client_id
    ORDER BY r.created_at DESC
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION job_market.get_client_profile IS 'Returns detailed client profile with statistics';
COMMENT ON FUNCTION job_market.get_client_jobs IS 'Returns jobs posted by client';
COMMENT ON FUNCTION job_market.get_client_reviews_given IS 'Returns reviews given by client to freelancers';
