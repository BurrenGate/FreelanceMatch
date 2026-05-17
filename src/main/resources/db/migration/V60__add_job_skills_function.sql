-- V60: Add function to get job skills for open jobs

-- Function to get skills required for a specific job
CREATE OR REPLACE FUNCTION job_market.get_job_skills(
    p_job_id BIGINT
)
RETURNS TABLE (
    skill_id INTEGER,
    skill_name VARCHAR(100),
    skill_category VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        s.id AS skill_id,
        s.name AS skill_name,
        s.category AS skill_category
    FROM job_required_skills jrs
    JOIN skills s ON s.id = jrs.skill_id
    WHERE jrs.job_id = p_job_id
    ORDER BY s.name;
END;
$$;

-- Enhanced function to get open jobs with skills
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
        j.id,
        j.client_id,
        j.title,
        j.description,
        j.budget_type,
        j.min_budget,
        j.max_budget,
        js.status_name,
        j.created_at,
        COALESCE(
            (SELECT COUNT(*)::INTEGER 
             FROM job_required_skills jrs 
             WHERE jrs.job_id = j.id),
            0
        ) AS required_skills_count
    FROM jobs j
    JOIN job_statuses js ON js.id = j.status_id
    WHERE js.status_name = 'OPEN'
    ORDER BY j.created_at DESC;
END;
$$;

COMMENT ON FUNCTION job_market.get_job_skills IS 'Returns all required skills for a specific job';
COMMENT ON FUNCTION job_market.get_open_jobs_with_details IS 'Returns OPEN jobs with count of required skills';
