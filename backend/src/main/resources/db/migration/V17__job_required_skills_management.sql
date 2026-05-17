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
    SELECT p.id INTO v_client_profile_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_client_email AND a.role_id = 1;

    IF v_client_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authenticated client profile not found';
    END IF;

    SELECT client_id INTO v_job_client_id
    FROM jobs
    WHERE id = p_job_id;

    IF v_job_client_id IS NULL THEN
        RAISE EXCEPTION 'Job % not found', p_job_id;
    END IF;

    IF v_job_client_id <> v_client_profile_id THEN
        RAISE EXCEPTION 'Only job owner can manage required skills';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM skills WHERE id = p_skill_id) THEN
        RAISE EXCEPTION 'Skill % not found', p_skill_id;
    END IF;

    IF EXISTS (
        SELECT 1
        FROM job_required_skills
        WHERE job_id = p_job_id AND skill_id = p_skill_id
    ) THEN
        RAISE EXCEPTION 'Skill % already required for job %', p_skill_id, p_job_id;
    END IF;

    INSERT INTO job_required_skills(job_id, skill_id)
    VALUES (p_job_id, p_skill_id);
END;
$$;

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
    SELECT p.id INTO v_client_profile_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_client_email AND a.role_id = 1;

    IF v_client_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authenticated client profile not found';
    END IF;

    SELECT client_id INTO v_job_client_id
    FROM jobs
    WHERE id = p_job_id;

    IF v_job_client_id IS NULL THEN
        RAISE EXCEPTION 'Job % not found', p_job_id;
    END IF;

    IF v_job_client_id <> v_client_profile_id THEN
        RAISE EXCEPTION 'Only job owner can manage required skills';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM job_required_skills
        WHERE job_id = p_job_id AND skill_id = p_skill_id
    ) THEN
        RAISE EXCEPTION 'Skill % is not required for job %', p_skill_id, p_job_id;
    END IF;

    DELETE FROM job_required_skills
    WHERE job_id = p_job_id AND skill_id = p_skill_id;
END;
$$;

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
    SELECT p.id INTO v_client_profile_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_client_email AND a.role_id = 1;

    IF v_client_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authenticated client profile not found';
    END IF;

    SELECT client_id INTO v_job_client_id
    FROM jobs
    WHERE id = p_job_id;

    IF v_job_client_id IS NULL THEN
        RAISE EXCEPTION 'Job % not found', p_job_id;
    END IF;

    IF v_job_client_id <> v_client_profile_id THEN
        RAISE EXCEPTION 'Only job owner can view required skills';
    END IF;

    RETURN QUERY
    SELECT s.id, s.name, s.category
    FROM job_required_skills jrs
    JOIN skills s ON s.id = jrs.skill_id
    WHERE jrs.job_id = p_job_id
    ORDER BY s.name;
END;
$$;
