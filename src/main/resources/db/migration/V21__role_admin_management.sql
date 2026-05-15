CREATE OR REPLACE FUNCTION admin_management.get_roles(
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    RETURN QUERY
    SELECT r.id, r.name
    FROM roles r
    ORDER BY r.id;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.create_role(
    p_name VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_name VARCHAR;
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    v_name := UPPER(BTRIM(p_name));

    IF v_name IS NULL OR v_name = '' THEN
        RAISE EXCEPTION 'Role name cannot be empty';
    END IF;

    IF EXISTS (SELECT 1 FROM roles WHERE UPPER(roles.name) = v_name) THEN
        RAISE EXCEPTION 'Role % already exists', v_name;
    END IF;

    RETURN QUERY
    INSERT INTO roles(name)
    VALUES (v_name)
    RETURNING roles.id, roles.name;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.update_role(
    p_role_id INTEGER,
    p_name VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_name VARCHAR;
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    v_name := UPPER(BTRIM(p_name));

    IF p_role_id IS NULL THEN
        RAISE EXCEPTION 'Role id is required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM roles WHERE roles.id = p_role_id) THEN
        RAISE EXCEPTION 'Role % not found', p_role_id;
    END IF;

    IF p_role_id IN (1, 2, 3) THEN
        RAISE EXCEPTION 'System roles cannot be renamed';
    END IF;

    IF v_name IS NULL OR v_name = '' THEN
        RAISE EXCEPTION 'Role name cannot be empty';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM roles
        WHERE UPPER(roles.name) = v_name
          AND roles.id <> p_role_id
    ) THEN
        RAISE EXCEPTION 'Role % already exists', v_name;
    END IF;

    RETURN QUERY
    UPDATE roles
    SET name = v_name
    WHERE roles.id = p_role_id
    RETURNING roles.id, roles.name;
END;
$$;

CREATE OR REPLACE PROCEDURE admin_management.delete_role(
    p_role_id INTEGER,
    p_admin_email VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF p_role_id IS NULL THEN
        RAISE EXCEPTION 'Role id is required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM roles WHERE roles.id = p_role_id) THEN
        RAISE EXCEPTION 'Role % not found', p_role_id;
    END IF;

    IF p_role_id IN (1, 2, 3) THEN
        RAISE EXCEPTION 'System roles cannot be deleted';
    END IF;

    IF EXISTS (SELECT 1 FROM accounts WHERE accounts.role_id = p_role_id) THEN
        RAISE EXCEPTION 'Role % is used by accounts and cannot be deleted', p_role_id;
    END IF;

    DELETE FROM roles WHERE roles.id = p_role_id;
END;
$$;
