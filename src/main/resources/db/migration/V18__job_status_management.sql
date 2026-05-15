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
    SELECT p.id INTO v_client_profile_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_client_email AND a.role_id = 1;

    IF v_client_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authenticated client profile not found';
    END IF;

    SELECT j.client_id, js.status_name
    INTO v_job_client_id, v_current_status_name
    FROM jobs j
    JOIN job_statuses js ON js.id = j.status_id
    WHERE j.id = p_job_id;

    IF v_job_client_id IS NULL THEN
        RAISE EXCEPTION 'Job % not found', p_job_id;
    END IF;

    IF v_job_client_id <> v_client_profile_id THEN
        RAISE EXCEPTION 'Only job owner can change status';
    END IF;

    SELECT id INTO v_new_status_id
    FROM job_statuses
    WHERE UPPER(status_name) = UPPER(p_new_status_name);

    IF v_new_status_id IS NULL THEN
        RAISE EXCEPTION 'Unknown status: %', p_new_status_name;
    END IF;

    IF v_current_status_name = 'COMPLETED' OR v_current_status_name = 'CANCELLED' THEN
        RAISE EXCEPTION 'Cannot change terminal status %', v_current_status_name;
    END IF;

    IF v_current_status_name = 'IN_PROGRESS' AND UPPER(p_new_status_name) <> 'COMPLETED' THEN
        RAISE EXCEPTION 'IN_PROGRESS can transition only to COMPLETED';
    END IF;

    IF v_current_status_name = 'OPEN' AND UPPER(p_new_status_name) NOT IN ('IN_PROGRESS', 'CANCELLED') THEN
        RAISE EXCEPTION 'OPEN can transition only to IN_PROGRESS or CANCELLED';
    END IF;

    UPDATE jobs
    SET status_id = v_new_status_id
    WHERE id = p_job_id;
END;
$$;

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
        RAISE EXCEPTION 'Only job owner can view status';
    END IF;

    RETURN QUERY
    SELECT j.id, js.id, js.status_name
    FROM jobs j
    JOIN job_statuses js ON js.id = j.status_id
    WHERE j.id = p_job_id;
END;
$$;
