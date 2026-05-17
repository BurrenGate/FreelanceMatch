-- V54: Fix get_client_profile - correct jobs.status_id reference

DROP FUNCTION IF EXISTS job_market.get_client_profile(BIGINT);

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
             WHERE j.client_id = p.id AND t.type = 'payment'),
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
             JOIN job_statuses js ON js.id = j.status_id
             WHERE j.client_id = p.id AND js.name = 'open'),
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
