-- V31: Filter jobs for freelancers - show only OPEN jobs

-- Function to get all OPEN jobs (for freelancers browsing)
CREATE OR REPLACE FUNCTION job_market.get_open_jobs()
RETURNS TABLE (
    id BIGINT,
    client_id BIGINT,
    title VARCHAR(255),
    description TEXT,
    budget_type VARCHAR(50),
    min_budget DECIMAL(15,2),
    max_budget DECIMAL(15,2),
    status_name VARCHAR(50),
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        j.id,
        j.client_id,
        j.title,
        j.description,
        j.budget_type,
        j.min_budget,
        j.max_budget,
        js.status_name,
        j.created_at
    FROM jobs j
    JOIN job_statuses js ON js.id = j.status_id
    WHERE js.status_name = 'OPEN'
    ORDER BY j.created_at DESC;
END;
$$;

COMMENT ON FUNCTION job_market.get_open_jobs IS 'Returns only OPEN jobs available for freelancers to browse and apply';
