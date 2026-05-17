-- V7: This script provides functions and procedures for managing jobs,
-- including job recommendations, skill requirements, and status changes.

CREATE SCHEMA IF NOT EXISTS job_management;

-- Function to get recommended jobs for a freelancer based on their skills.
-- It calculates a match percentage and returns jobs with a match of 50% or higher.
CREATE OR REPLACE FUNCTION job_management.get_recommended_jobs(p_email VARCHAR(255))
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
    match_percentage NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_freelancer_id BIGINT;
BEGIN
    -- Find the freelancer's profile ID by email.
    SELECT p.id INTO v_freelancer_id
    FROM accounts a
    JOIN profiles p ON a.id = p.account_id
    WHERE a.email = p_email;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Freelancer profile not found for email: %', p_email;
    END IF;

    -- Return a query that calculates the relevance of jobs.
    RETURN QUERY
    WITH JobSkillCounts AS (
        -- Count the total number of required skills for each job.
        SELECT job_id, COUNT(skill_id) AS total_req
        FROM job_required_skills
        GROUP BY job_id
    ),
    MatchedSkills AS (
        -- Count the number of matched skills for the freelancer.
        SELECT jrs.job_id, COUNT(ps.skill_id) AS matched_req
        FROM job_required_skills jrs
        JOIN profile_skills ps ON ps.skill_id = jrs.skill_id
        WHERE ps.profile_id = v_freelancer_id
        GROUP BY jrs.job_id
    )
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
        -- Calculate the match percentage. NULLIF prevents division by zero.
        ROUND(COALESCE(m.matched_req, 0) * 100.0 / NULLIF(c.total_req, 0), 2) AS match_percentage
    FROM jobs j
    JOIN job_statuses js ON j.status_id = js.id
    JOIN JobSkillCounts c ON j.id = c.job_id -- Only include jobs with skill requirements.
    LEFT JOIN MatchedSkills m ON j.id = m.job_id
    WHERE js.status_name = 'OPEN' -- Only open jobs.
      AND ROUND(COALESCE(m.matched_req, 0) * 100.0 / NULLIF(c.total_req, 0), 2) >= 50.00 -- Filter out matches below 50%.
    ORDER BY match_percentage DESC, j.created_at DESC; -- Sort by best match and then by newest.
END;
$$;
COMMENT ON FUNCTION job_management.get_recommended_jobs(VARCHAR)
IS 'Retrieves recommended jobs for a freelancer based on skill match percentage.';

-- Procedure to add a required skill to a job.
-- Only the job owner can perform this action.
CREATE OR REPLACE PROCEDURE job_management.add_job_required_skill(
    p_job_id BIGINT,
    p_skill_id INTEGER,
    p_client_email VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_client_profile_id BIGINT;
    v_job_client_id BIGINT;
BEGIN
    -- Get the client's profile ID from their email.
    SELECT p.id INTO v_client_profile_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_client_email AND a.role_id = 1;

    IF v_client_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authenticated client profile not found.';
    END IF;

    -- Get the client ID of the job.
    SELECT client_id INTO v_job_client_id
    FROM jobs
    WHERE id = p_job_id;

    IF v_job_client_id IS NULL THEN
        RAISE EXCEPTION 'Job with ID % not found.', p_job_id;
    END IF;

    -- Ensure the authenticated user is the job owner.
    IF v_job_client_id <> v_client_profile_id THEN
        RAISE EXCEPTION 'Only the job owner can manage required skills.';
    END IF;

    -- Check if the skill exists.
    IF NOT EXISTS (SELECT 1 FROM skills WHERE id = p_skill_id) THEN
        RAISE EXCEPTION 'Skill with ID % not found.', p_skill_id;
    END IF;

    -- Check if the skill is already required for the job.
    IF EXISTS (
        SELECT 1
        FROM job_required_skills
        WHERE job_id = p_job_id AND skill_id = p_skill_id
    ) THEN
        RAISE EXCEPTION 'Skill % is already required for job %.', p_skill_id, p_job_id;
    END IF;

    -- Add the skill to the job's required skills.
    INSERT INTO job_required_skills(job_id, skill_id)
    VALUES (p_job_id, p_skill_id);
END;
$$;
COMMENT ON PROCEDURE job_management.add_job_required_skill(BIGINT, INTEGER, VARCHAR)
IS 'Adds a required skill to a job, with ownership verification.';

-- Procedure to remove a required skill from a job.
-- Only the job owner can perform this action.
CREATE OR REPLACE PROCEDURE job_management.remove_job_required_skill(
    p_job_id BIGINT,
    p_skill_id INTEGER,
    p_client_email VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_client_profile_id BIGINT;
    v_job_client_id BIGINT;
BEGIN
    -- Get the client's profile ID from their email.
    SELECT p.id INTO v_client_profile_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_client_email AND a.role_id = 1;

    IF v_client_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authenticated client profile not found.';
    END IF;

    -- Get the client ID of the job.
    SELECT client_id INTO v_job_client_id
    FROM jobs
    WHERE id = p_job_id;

    IF v_job_client_id IS NULL THEN
        RAISE EXCEPTION 'Job with ID % not found.', p_job_id;
    END IF;

    -- Ensure the authenticated user is the job owner.
    IF v_job_client_id <> v_client_profile_id THEN
        RAISE EXCEPTION 'Only the job owner can manage required skills.';
    END IF;

    -- Check if the skill is required for the job.
    IF NOT EXISTS (
        SELECT 1
        FROM job_required_skills
        WHERE job_id = p_job_id AND skill_id = p_skill_id
    ) THEN
        RAISE EXCEPTION 'Skill % is not required for job %.', p_skill_id, p_job_id;
    END IF;

    -- Remove the skill from the job's required skills.
    DELETE FROM job_required_skills
    WHERE job_id = p_job_id AND skill_id = p_skill_id;
END;
$$;
COMMENT ON PROCEDURE job_management.remove_job_required_skill(BIGINT, INTEGER, VARCHAR)
IS 'Removes a required skill from a job, with ownership verification.';

-- Function to get the required skills for a job.
-- Only the job owner can perform this action.
CREATE OR REPLACE FUNCTION job_management.get_job_required_skills(
    p_job_id BIGINT,
    p_client_email VARCHAR
)
RETURNS TABLE(
    skill_id INTEGER,
    skill_name VARCHAR,
    category VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_client_profile_id BIGINT;
    v_job_client_id BIGINT;
BEGIN
    -- Get the client's profile ID from their email.
    SELECT p.id INTO v_client_profile_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_client_email AND a.role_id = 1;

    IF v_client_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authenticated client profile not found.';
    END IF;

    -- Get the client ID of the job.
    SELECT client_id INTO v_job_client_id
    FROM jobs
    WHERE id = p_job_id;

    IF v_job_client_id IS NULL THEN
        RAISE EXCEPTION 'Job with ID % not found.', p_job_id;
    END IF;

    -- Ensure the authenticated user is the job owner.
    IF v_job_client_id <> v_client_profile_id THEN
        RAISE EXCEPTION 'Only the job owner can view required skills.';
    END IF;

    -- Return the required skills for the job.
    RETURN QUERY
    SELECT s.id, s.name, s.category
    FROM job_required_skills jrs
    JOIN skills s ON s.id = jrs.skill_id
    WHERE jrs.job_id = p_job_id
    ORDER BY s.name;
END;
$$;
COMMENT ON FUNCTION job_management.get_job_required_skills(BIGINT, VARCHAR)
IS 'Retrieves the required skills for a job, with ownership verification.';

-- Procedure to change the status of a job.
-- Only the job owner can perform this action.
CREATE OR REPLACE PROCEDURE job_management.change_job_status(
    p_job_id BIGINT,
    p_new_status_name VARCHAR,
    p_client_email VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_client_profile_id BIGINT;
    v_job_client_id BIGINT;
    v_current_status_name VARCHAR;
    v_new_status_id INTEGER;
BEGIN
    -- Get the client's profile ID from their email.
    SELECT p.id INTO v_client_profile_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_client_email AND a.role_id = 1;

    IF v_client_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authenticated client profile not found.';
    END IF;

    -- Get the job's client ID and current status.
    SELECT j.client_id, js.status_name
    INTO v_job_client_id, v_current_status_name
    FROM jobs j
    JOIN job_statuses js ON js.id = j.status_id
    WHERE j.id = p_job_id;

    IF v_job_client_id IS NULL THEN
        RAISE EXCEPTION 'Job with ID % not found.', p_job_id;
    END IF;

    -- Ensure the authenticated user is the job owner.
    IF v_job_client_id <> v_client_profile_id THEN
        RAISE EXCEPTION 'Only the job owner can change the job status.';
    END IF;

    -- Get the ID of the new status.
    SELECT id INTO v_new_status_id
    FROM job_statuses
    WHERE UPPER(status_name) = UPPER(p_new_status_name);

    IF v_new_status_id IS NULL THEN
        RAISE EXCEPTION 'Unknown status: %', p_new_status_name;
    END IF;

    -- Prevent changing a terminal status.
    IF v_current_status_name IN ('COMPLETED', 'CANCELLED') THEN
        RAISE EXCEPTION 'Cannot change a terminal status: %', v_current_status_name;
    END IF;

    -- Enforce valid status transitions.
    IF v_current_status_name = 'IN_PROGRESS' AND UPPER(p_new_status_name) <> 'COMPLETED' THEN
        RAISE EXCEPTION 'A job in progress can only transition to COMPLETED.';
    END IF;

    IF v_current_status_name = 'OPEN' AND UPPER(p_new_status_name) NOT IN ('IN_PROGRESS', 'CANCELLED') THEN
        RAISE EXCEPTION 'An open job can only transition to IN_PROGRESS or CANCELLED.';
    END IF;

    -- Update the job status.
    UPDATE jobs
    SET status_id = v_new_status_id
    WHERE id = p_job_id;
END;
$$;
COMMENT ON PROCEDURE job_management.change_job_status(BIGINT, VARCHAR, VARCHAR)
IS 'Changes the status of a job, enforcing valid transitions and ownership.';

-- Function to get the status of a job.
-- Only the job owner can perform this action.
CREATE OR REPLACE FUNCTION job_management.get_job_status(
    p_job_id BIGINT,
    p_client_email VARCHAR
)
RETURNS TABLE(
    job_id BIGINT,
    status_id INTEGER,
    status_name VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_client_profile_id BIGINT;
    v_job_client_id BIGINT;
BEGIN
    -- Get the client's profile ID from their email.
    SELECT p.id INTO v_client_profile_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_client_email AND a.role_id = 1;

    IF v_client_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authenticated client profile not found.';
    END IF;

    -- Get the client ID of the job.
    SELECT client_id INTO v_job_client_id
    FROM jobs
    WHERE id = p_job_id;

    IF v_job_client_id IS NULL THEN
        RAISE EXCEPTION 'Job with ID % not found.', p_job_id;
    END IF;

    -- Ensure the authenticated user is the job owner.
    IF v_job_client_id <> v_client_profile_id THEN
        RAISE EXCEPTION 'Only the job owner can view the job status.';
    END IF;

    -- Return the job status.
    RETURN QUERY
    SELECT j.id, js.id, js.status_name
    FROM jobs j
    JOIN job_statuses js ON js.id = j.status_id
    WHERE j.id = p_job_id;
END;
$$;
COMMENT ON FUNCTION job_management.get_job_status(BIGINT, VARCHAR)
IS 'Retrieves the status of a job, with ownership verification.';

-- Function to get jobs that require all of the given skill IDs.
CREATE OR REPLACE FUNCTION job_management.get_jobs_by_skill_ids(
    p_skill_ids INTEGER[]
)
RETURNS TABLE (
    job_id      BIGINT,
    title       VARCHAR(255),
    min_budget  DECIMAL(15,2),
    max_budget  DECIMAL(15,2),
    created_at  TIMESTAMP
)
LANGUAGE plpgsql AS $$
DECLARE
    v_skill_count INT;
BEGIN
    IF p_skill_ids IS NULL OR array_length(p_skill_ids, 1) IS NULL THEN
        RAISE EXCEPTION 'The skill_ids array must not be empty.';
    END IF;

    v_skill_count := array_length(p_skill_ids, 1);

    RETURN QUERY
    SELECT  j.id,
            j.title,
            j.min_budget,
            j.max_budget,
            j.created_at
    FROM    jobs j
    JOIN    job_statuses js ON js.id = j.status_id
    WHERE   js.status_name = 'OPEN'
      AND   (
                SELECT COUNT(*)
                FROM   job_required_skills jrs
                WHERE  jrs.job_id   = j.id
                  AND  jrs.skill_id = ANY(p_skill_ids)
            ) = v_skill_count
    ORDER BY j.created_at DESC;
END;
$$;
COMMENT ON FUNCTION job_management.get_jobs_by_skill_ids(INTEGER[])
IS 'Finds open jobs that require all of the specified skills.';

-- Function to get freelancers who have all of the given skill IDs.
CREATE OR REPLACE FUNCTION job_management.get_freelancers_by_skill_ids(
    p_skill_ids INTEGER[]
)
RETURNS TABLE (
    profile_id  BIGINT,
    full_name   TEXT,
    hourly_rate DECIMAL(10,2),
    email       VARCHAR(255)
)
LANGUAGE plpgsql AS $$
DECLARE
    v_skill_count INT;
BEGIN
    IF p_skill_ids IS NULL OR array_length(p_skill_ids, 1) IS NULL THEN
        RAISE EXCEPTION 'The skill_ids array must not be empty.';
    END IF;

    SELECT COUNT(DISTINCT s)
    INTO v_skill_count
    FROM unnest(p_skill_ids) AS s;

    RETURN QUERY
    SELECT  p.id,
            (p.first_name || ' ' || p.last_name)::TEXT,
            p.hourly_rate,
            a.email
    FROM    profiles p
    JOIN    accounts  a  ON a.id = p.account_id
    JOIN    profile_skills ps ON ps.profile_id = p.id
    WHERE   a.role_id  = 2 -- freelancers only
      AND   ps.skill_id = ANY(p_skill_ids)
    GROUP BY p.id, p.first_name, p.last_name, p.hourly_rate, a.email
    HAVING  COUNT(DISTINCT ps.skill_id) = v_skill_count
    ORDER BY p.hourly_rate ASC NULLS LAST;
END;
$$;
COMMENT ON FUNCTION job_management.get_freelancers_by_skill_ids(INTEGER[])
IS 'Finds freelancers who possess all of the specified skills.';

-- Function to get the contract history for a freelancer as a JSONB array.
CREATE OR REPLACE FUNCTION job_management.get_contract_history(
    p_profile_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(
        JSONB_AGG(
            JSONB_BUILD_OBJECT(
                'contractId',   c.id,
                'jobTitle',     j.title,
                'status',       c.status,
                'totalAmount',  c.total_amount,
                'skills',       (
                    SELECT ARRAY_AGG(s.name)
                    FROM   job_required_skills jrs
                    JOIN   skills s ON s.id = jrs.skill_id
                    WHERE  jrs.job_id = j.id
                )
            )
            ORDER BY c.id DESC
        ),
        '[]'::JSONB
    )
    INTO v_result
    FROM  contracts c
    JOIN  jobs j ON j.id = c.job_id
    WHERE c.freelancer_id = p_profile_id;

    RETURN v_result;
END;
$$;
COMMENT ON FUNCTION job_management.get_contract_history(BIGINT)
IS 'Retrieves the contract history for a freelancer in JSONB format.';
