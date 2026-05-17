CREATE SCHEMA IF NOT EXISTS admin_management;

CREATE OR REPLACE FUNCTION admin_management.ensure_admin_email(
    p_admin_email VARCHAR
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_admin_account_id BIGINT;
BEGIN
    SELECT a.id
    INTO v_admin_account_id
    FROM accounts a
    WHERE a.email = p_admin_email
      AND a.role_id = 3;

    IF v_admin_account_id IS NULL THEN
        RAISE EXCEPTION 'Only admin users can perform this action';
    END IF;

    RETURN v_admin_account_id;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.get_accounts(
    p_status VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id BIGINT,
    email VARCHAR,
    role_id INTEGER,
    role_name VARCHAR,
    status VARCHAR,
    last_login TIMESTAMP,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    RETURN QUERY
    SELECT a.id,
           a.email,
           a.role_id,
           r.name,
           a.status,
           a.last_login,
           a.created_at
    FROM accounts a
    JOIN roles r ON r.id = a.role_id
    WHERE p_status IS NULL OR LOWER(a.status) = LOWER(p_status)
    ORDER BY a.created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.get_account_by_id(
    p_account_id BIGINT,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id BIGINT,
    email VARCHAR,
    role_id INTEGER,
    role_name VARCHAR,
    status VARCHAR,
    last_login TIMESTAMP,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF NOT EXISTS (SELECT 1 FROM accounts WHERE accounts.id = p_account_id) THEN
        RAISE EXCEPTION 'Account % not found', p_account_id;
    END IF;

    RETURN QUERY
    SELECT a.id,
           a.email,
           a.role_id,
           r.name,
           a.status,
           a.last_login,
           a.created_at
    FROM accounts a
    JOIN roles r ON r.id = a.role_id
    WHERE a.id = p_account_id;
END;
$$;

CREATE OR REPLACE PROCEDURE admin_management.set_account_status(
    p_account_id BIGINT,
    p_status VARCHAR,
    p_admin_email VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_admin_account_id BIGINT;
BEGIN
    v_admin_account_id := admin_management.ensure_admin_email(p_admin_email);

    IF p_status IS NULL OR btrim(p_status) = '' THEN
        RAISE EXCEPTION 'Status cannot be empty';
    END IF;

    IF LOWER(p_status) NOT IN ('active', 'suspended') THEN
        RAISE EXCEPTION 'Unsupported status %. Allowed: active, suspended', p_status;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM accounts WHERE accounts.id = p_account_id) THEN
        RAISE EXCEPTION 'Account % not found', p_account_id;
    END IF;

    IF p_account_id = v_admin_account_id THEN
        RAISE EXCEPTION 'Admin cannot change own status';
    END IF;

    UPDATE accounts
    SET status = LOWER(p_status)
    WHERE id = p_account_id;
END;
$$;
