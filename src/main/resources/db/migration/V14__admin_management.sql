-- V14: This script provides a suite of administrative functions for managing core aspects of the application,
-- such as user accounts, roles, skills, and more. All functions in this schema require admin privileges.

CREATE SCHEMA IF NOT EXISTS admin_management;

-- Helper function to ensure that the calling user is an administrator.
CREATE OR REPLACE FUNCTION admin_management.ensure_admin_email(p_admin_email VARCHAR)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_admin_account_id BIGINT;
BEGIN
    SELECT a.id INTO v_admin_account_id
    FROM accounts a
    WHERE a.email = p_admin_email AND a.role_id = 3; -- Role 3 is 'admin'

    IF v_admin_account_id IS NULL THEN
        RAISE EXCEPTION 'This action requires administrator privileges.';
    END IF;

    RETURN v_admin_account_id;
END;
$$;
COMMENT ON FUNCTION admin_management.ensure_admin_email(VARCHAR)
IS 'Verifies that the provided email belongs to an administrator and returns their account ID.';

-- =============================================================================
-- Account Management Functions
-- =============================================================================

-- Function to get a list of accounts, optionally filtered by status.
CREATE OR REPLACE FUNCTION admin_management.get_accounts(
    p_status VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id BIGINT, email VARCHAR, role_name VARCHAR, status VARCHAR,
    last_login TIMESTAMP, created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    RETURN QUERY
    SELECT a.id, a.email, r.name, a.status, a.last_login, a.created_at
    FROM accounts a
    JOIN roles r ON r.id = a.role_id
    WHERE p_status IS NULL OR LOWER(a.status) = LOWER(p_status)
    ORDER BY a.created_at DESC;
END;
$$;
COMMENT ON FUNCTION admin_management.get_accounts(VARCHAR, VARCHAR)
IS 'Retrieves a list of user accounts, filterable by status.';

-- Procedure to set the status of a user account (e.g., 'active' or 'suspended').
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

    IF LOWER(p_status) NOT IN ('active', 'suspended') THEN
        RAISE EXCEPTION 'Invalid status: "%". Allowed values are "active" or "suspended".', p_status;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM accounts WHERE id = p_account_id) THEN
        RAISE EXCEPTION 'Account with ID % not found.', p_account_id;
    END IF;
    IF p_account_id = v_admin_account_id THEN
        RAISE EXCEPTION 'Administrators cannot change their own status.';
    END IF;

    UPDATE accounts SET status = LOWER(p_status) WHERE id = p_account_id;
END;
$$;
COMMENT ON PROCEDURE admin_management.set_account_status(BIGINT, VARCHAR, VARCHAR)
IS 'Updates the status of a user account (e.g., to suspend or reactivate).';

-- =============================================================================
-- Role and Skill Management Functions
-- =============================================================================

-- Function to get all roles.
CREATE OR REPLACE FUNCTION admin_management.get_roles(p_admin_email VARCHAR)
RETURNS TABLE(id INTEGER, name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    RETURN QUERY SELECT r.id, r.name FROM roles r ORDER BY r.id;
END;
$$;
COMMENT ON FUNCTION admin_management.get_roles(VARCHAR) IS 'Retrieves all user roles.';

-- Function to get all skills, optionally filtered by category.
CREATE OR REPLACE FUNCTION admin_management.get_skills(
    p_category VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(id INTEGER, name VARCHAR, category VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    RETURN QUERY
    SELECT s.id, s.name, s.category
    FROM skills s
    WHERE p_category IS NULL OR LOWER(s.category) = LOWER(p_category)
    ORDER BY s.name;
END;
$$;
COMMENT ON FUNCTION admin_management.get_skills(VARCHAR, VARCHAR)
IS 'Retrieves skills, optionally filtered by category.';

-- =============================================================================
-- Job Status Management Functions
-- =============================================================================

-- Function to get all job statuses.
CREATE OR REPLACE FUNCTION admin_management.get_job_statuses(p_admin_email VARCHAR)
RETURNS TABLE(id INTEGER, status_name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    RETURN QUERY SELECT js.id, js.status_name FROM job_statuses js ORDER BY js.id;
END;
$$;
COMMENT ON FUNCTION admin_management.get_job_statuses(VARCHAR)
IS 'Retrieves all possible job statuses.';

-- =============================================================================
-- Transaction and Review Management (for moderation)
-- =============================================================================

-- Function to get transactions with filtering options.
CREATE OR REPLACE FUNCTION admin_management.get_transactions(
    p_contract_id BIGINT,
    p_type VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(id BIGINT, contract_id BIGINT, amount DECIMAL, type VARCHAR, created_at TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    RETURN QUERY
    SELECT t.id, t.contract_id, t.amount, t.type, t.created_at
    FROM transactions t
    WHERE (p_contract_id IS NULL OR t.contract_id = p_contract_id)
      AND (p_type IS NULL OR UPPER(t.type) = UPPER(p_type))
    ORDER BY t.created_at DESC;
END;
$$;
COMMENT ON FUNCTION admin_management.get_transactions(BIGINT, VARCHAR, VARCHAR)
IS 'Retrieves financial transactions with optional filters for contract and type.';

-- Function to get reviews with filtering options.
CREATE OR REPLACE FUNCTION admin_management.get_reviews(
    p_contract_id BIGINT,
    p_reviewer_id BIGINT,
    p_admin_email VARCHAR
)
RETURNS TABLE(id BIGINT, contract_id BIGINT, reviewer_id BIGINT, rating INTEGER, comment TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    RETURN QUERY
    SELECT r.id, r.contract_id, r.reviewer_id, r.rating, r.comment
    FROM reviews r
    WHERE (p_contract_id IS NULL OR r.contract_id = p_contract_id)
      AND (p_reviewer_id IS NULL OR r.reviewer_id = p_reviewer_id)
    ORDER BY r.id DESC;
END;
$$;
COMMENT ON FUNCTION admin_management.get_reviews(BIGINT, BIGINT, VARCHAR)
IS 'Retrieves reviews with optional filters for contract and reviewer.';

-- Procedure to delete a review.
CREATE OR REPLACE PROCEDURE admin_management.delete_review(
    p_review_id BIGINT,
    p_admin_email VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    IF NOT EXISTS (SELECT 1 FROM reviews WHERE id = p_review_id) THEN
        RAISE EXCEPTION 'Review with ID % not found.', p_review_id;
    END IF;
    DELETE FROM reviews WHERE id = p_review_id;
END;
$$;
COMMENT ON PROCEDURE admin_management.delete_review(BIGINT, VARCHAR)
IS 'Allows an administrator to delete a review.';
