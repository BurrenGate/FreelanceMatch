-- V56: Fix get_client_jobs and get_client_reviews_given functions

DROP FUNCTION IF EXISTS job_market.get_client_jobs(BIGINT, INTEGER);
DROP FUNCTION IF EXISTS job_market.get_client_reviews_given(BIGINT, INTEGER);

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
        COALESCE(j.max_budget, j.min_budget, 0.00) AS budget,
        js.status_name AS status,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM proposals pr 
             WHERE pr.job_id = j.id),
            0
        ) AS proposals_count,
        j.created_at
    FROM jobs j
    LEFT JOIN job_statuses js ON js.id = j.status_id
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
