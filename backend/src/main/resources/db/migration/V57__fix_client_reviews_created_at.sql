-- V57: Fix get_client_reviews_given - remove created_at from reviews

DROP FUNCTION IF EXISTS job_market.get_client_reviews_given(BIGINT, INTEGER);

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
        c.created_at
    FROM reviews r
    JOIN contracts c ON c.id = r.contract_id
    JOIN jobs j ON j.id = c.job_id
    JOIN profiles freelancer_profile ON freelancer_profile.id = c.freelancer_id
    WHERE r.reviewer_id = p_client_id
    ORDER BY c.created_at DESC
    LIMIT p_limit;
END;
$$;
