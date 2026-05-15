-- V61: Add function to get all proposals with detailed information

CREATE OR REPLACE FUNCTION job_market.get_all_proposals_detailed()
RETURNS TABLE (
    proposal_id BIGINT,
    job_id BIGINT,
    freelancer_id BIGINT,
    bid_amount DECIMAL(15,2),
    cover_letter TEXT,
    status VARCHAR(50),
    created_at TIMESTAMP,
    is_accepted BOOLEAN,
    job_title VARCHAR(255),
    job_description TEXT,
    job_min_budget DECIMAL(15,2),
    job_max_budget DECIMAL(15,2),
    job_status VARCHAR(50),
    freelancer_name TEXT,
    freelancer_email VARCHAR(255),
    freelancer_hourly_rate DECIMAL(10,2),
    freelancer_rating DECIMAL(3,2),
    freelancer_bio TEXT,
    client_id BIGINT,
    client_name TEXT,
    client_email VARCHAR(255)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id AS proposal_id,
        p.job_id,
        p.freelancer_id,
        p.bid_amount,
        p.cover_letter,
        p.status,
        p.created_at,
        CASE WHEN p.status = 'accepted' THEN true ELSE false END AS is_accepted,
        j.title AS job_title,
        j.description AS job_description,
        j.min_budget AS job_min_budget,
        j.max_budget AS job_max_budget,
        js.status_name AS job_status,
        CONCAT(fp.first_name, ' ', fp.last_name)::TEXT AS freelancer_name,
        fa.email AS freelancer_email,
        fp.hourly_rate AS freelancer_hourly_rate,
        COALESCE(job_market.get_freelancer_rating(fp.id), 0.00) AS freelancer_rating,
        fp.bio AS freelancer_bio,
        j.client_id,
        CONCAT(cp.first_name, ' ', cp.last_name)::TEXT AS client_name,
        ca.email AS client_email
    FROM proposals p
    JOIN jobs j ON j.id = p.job_id
    JOIN job_statuses js ON js.id = j.status_id
    JOIN profiles fp ON fp.id = p.freelancer_id
    JOIN accounts fa ON fa.id = fp.account_id
    JOIN profiles cp ON cp.id = j.client_id
    JOIN accounts ca ON ca.id = cp.account_id
    ORDER BY p.created_at DESC;
END;
$$;

COMMENT ON FUNCTION job_market.get_all_proposals_detailed IS 'Returns all proposals with complete job, freelancer, and client information';
