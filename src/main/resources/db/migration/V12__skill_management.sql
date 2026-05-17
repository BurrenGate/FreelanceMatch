-- V12: This script implements a system for suggesting and managing new skills.
-- It allows users to propose new skills and provides administrators with the tools
-- to review, approve, or reject these suggestions.

CREATE SCHEMA IF NOT EXISTS skill_management;

-- Indexes for faster querying of skill suggestions.
CREATE INDEX IF NOT EXISTS idx_skill_suggestions_status ON skill_suggestions(status);
CREATE INDEX IF NOT EXISTS idx_skill_suggestions_suggested_by ON skill_suggestions(suggested_by);

-- =============================================================================
-- Skill Suggestion Workflow Functions
-- =============================================================================

-- Function for users to suggest a new skill.
CREATE OR REPLACE FUNCTION skill_management.suggest_skill(
    p_name VARCHAR(100),
    p_category VARCHAR(100),
    p_user_id BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_suggestion_id BIGINT;
BEGIN
    -- Prevent duplicate suggestions for existing skills.
    IF EXISTS (SELECT 1 FROM skills WHERE LOWER(name) = LOWER(p_name)) THEN
        RAISE EXCEPTION 'The skill "%" already exists in the system.', p_name;
    END IF;

    -- Prevent duplicate pending suggestions.
    IF EXISTS (SELECT 1 FROM skill_suggestions WHERE LOWER(name) = LOWER(p_name) AND status = 'pending') THEN
        RAISE EXCEPTION 'A suggestion for the skill "%" is already pending approval.', p_name;
    END IF;

    -- Insert the new skill suggestion.
    INSERT INTO skill_suggestions (name, category, suggested_by)
    VALUES (p_name, p_category, p_user_id)
    RETURNING id INTO v_suggestion_id;

    RETURN v_suggestion_id;
END;
$$;
COMMENT ON FUNCTION skill_management.suggest_skill(VARCHAR, VARCHAR, BIGINT)
IS 'Allows a user to suggest a new skill for addition to the platform.';

-- Function for admins to approve a skill suggestion.
CREATE OR REPLACE FUNCTION skill_management.approve_skill_suggestion(
    p_suggestion_id BIGINT,
    p_admin_id BIGINT
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_skill_name VARCHAR(100);
    v_skill_category VARCHAR(100);
    v_new_skill_id INTEGER;
BEGIN
    -- This function should be restricted to admin users. (Handled by application-level security)

    -- Retrieve the suggestion details.
    SELECT name, category
    INTO v_skill_name, v_skill_category
    FROM skill_suggestions
    WHERE id = p_suggestion_id AND status = 'pending';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pending skill suggestion with ID % not found.', p_suggestion_id;
    END IF;

    -- Add the new skill to the main skills table.
    INSERT INTO skills (name, category)
    VALUES (v_skill_name, v_skill_category)
    ON CONFLICT (name) DO NOTHING
    RETURNING id INTO v_new_skill_id;

    -- Update the suggestion's status to 'approved'.
    UPDATE skill_suggestions
    SET status = 'approved',
        reviewed_by = p_admin_id,
        reviewed_at = NOW()
    WHERE id = p_suggestion_id;

    RETURN v_new_skill_id;
END;
$$;
COMMENT ON FUNCTION skill_management.approve_skill_suggestion(BIGINT, BIGINT)
IS 'Allows an administrator to approve a pending skill suggestion, adding it to the system.';

-- Function for admins to reject a skill suggestion.
CREATE OR REPLACE FUNCTION skill_management.reject_skill_suggestion(
    p_suggestion_id BIGINT,
    p_admin_id BIGINT,
    p_admin_comment TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- This function should be restricted to admin users. (Handled by application-level security)

    -- Ensure a comment is provided for the rejection.
    IF p_admin_comment IS NULL OR TRIM(p_admin_comment) = '' THEN
        RAISE EXCEPTION 'An administrator comment is required when rejecting a skill suggestion.';
    END IF;

    -- Update the suggestion's status to 'rejected'.
    UPDATE skill_suggestions
    SET status = 'rejected',
        reviewed_by = p_admin_id,
        reviewed_at = NOW(),
        admin_comment = p_admin_comment
    WHERE id = p_suggestion_id AND status = 'pending';

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pending skill suggestion with ID % not found.', p_suggestion_id;
    END IF;
END;
$$;
COMMENT ON FUNCTION skill_management.reject_skill_suggestion(BIGINT, BIGINT, TEXT)
IS 'Allows an administrator to reject a pending skill suggestion, with a required comment.';

-- =============================================================================
-- Data Retrieval Functions
-- =============================================================================

-- Function to get all skill suggestions, filterable by status (for admins).
CREATE OR REPLACE FUNCTION skill_management.get_skill_suggestions(
    p_status VARCHAR(20) DEFAULT NULL
)
RETURNS TABLE (
    suggestion_id BIGINT,
    skill_name VARCHAR(100),
    skill_category VARCHAR(100),
    status VARCHAR(20),
    suggested_by_name TEXT,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ss.id,
        ss.name,
        ss.category,
        ss.status,
        (p.first_name || ' ' || p.last_name)::TEXT,
        ss.created_at
    FROM skill_suggestions ss
    JOIN profiles p ON p.id = ss.suggested_by
    WHERE p_status IS NULL OR ss.status = p_status
    ORDER BY ss.created_at DESC;
END;
$$;
COMMENT ON FUNCTION skill_management.get_skill_suggestions(VARCHAR)
IS 'Retrieves a list of skill suggestions, optionally filtered by status (for admin use).';

-- Function for users to view their own skill suggestions.
CREATE OR REPLACE FUNCTION skill_management.get_my_skill_suggestions(
    p_user_id BIGINT
)
RETURNS TABLE (
    suggestion_id BIGINT,
    skill_name VARCHAR(100),
    status VARCHAR(20),
    admin_comment TEXT,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        ss.id,
        ss.name,
        ss.status,
        ss.admin_comment,
        ss.created_at
    FROM skill_suggestions ss
    WHERE ss.suggested_by = p_user_id
    ORDER BY ss.created_at DESC;
END;
$$;
COMMENT ON FUNCTION skill_management.get_my_skill_suggestions(BIGINT)
IS 'Allows a user to view the history and status of their own skill suggestions.';
