CREATE OR REPLACE FUNCTION admin_management.get_job_statuses(
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    status_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    RETURN QUERY
    SELECT js.id, js.status_name
    FROM job_statuses js
    ORDER BY js.id;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.create_job_status(
    p_status_name VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    status_name VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status_name VARCHAR;
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    v_status_name := UPPER(BTRIM(p_status_name));

    IF v_status_name IS NULL OR v_status_name = '' THEN
        RAISE EXCEPTION 'Status name cannot be empty';
    END IF;

    IF EXISTS (SELECT 1 FROM job_statuses WHERE UPPER(job_statuses.status_name) = v_status_name) THEN
        RAISE EXCEPTION 'Job status % already exists', v_status_name;
    END IF;

    RETURN QUERY
    INSERT INTO job_statuses(status_name)
    VALUES (v_status_name)
    RETURNING job_statuses.id, job_statuses.status_name;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.update_job_status(
    p_status_id INTEGER,
    p_status_name VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    status_name VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_status_name VARCHAR;
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    v_status_name := UPPER(BTRIM(p_status_name));

    IF p_status_id IS NULL THEN
        RAISE EXCEPTION 'Status id is required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM job_statuses WHERE job_statuses.id = p_status_id) THEN
        RAISE EXCEPTION 'Job status % not found', p_status_id;
    END IF;

    IF p_status_id IN (1, 2, 3, 4) THEN
        RAISE EXCEPTION 'System job statuses cannot be renamed';
    END IF;

    IF v_status_name IS NULL OR v_status_name = '' THEN
        RAISE EXCEPTION 'Status name cannot be empty';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM job_statuses
        WHERE UPPER(job_statuses.status_name) = v_status_name
          AND job_statuses.id <> p_status_id
    ) THEN
        RAISE EXCEPTION 'Job status % already exists', v_status_name;
    END IF;

    RETURN QUERY
    UPDATE job_statuses
    SET status_name = v_status_name
    WHERE job_statuses.id = p_status_id
    RETURNING job_statuses.id, job_statuses.status_name;
END;
$$;

CREATE OR REPLACE PROCEDURE admin_management.delete_job_status(
    p_status_id INTEGER,
    p_admin_email VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF p_status_id IS NULL THEN
        RAISE EXCEPTION 'Status id is required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM job_statuses WHERE job_statuses.id = p_status_id) THEN
        RAISE EXCEPTION 'Job status % not found', p_status_id;
    END IF;

    IF p_status_id IN (1, 2, 3, 4) THEN
        RAISE EXCEPTION 'System job statuses cannot be deleted';
    END IF;

    IF EXISTS (SELECT 1 FROM jobs WHERE jobs.status_id = p_status_id) THEN
        RAISE EXCEPTION 'Job status % is used by jobs and cannot be deleted', p_status_id;
    END IF;

    DELETE FROM job_statuses WHERE job_statuses.id = p_status_id;
END;
$$;
