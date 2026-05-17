-- V49: Skill Suggestions System
-- Users (clients and freelancers) can suggest new skills
-- Admins must approve suggestions before they become available

-- Create table for skill suggestions
CREATE TABLE skill_suggestions (
    id              BIGSERIAL PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    category        VARCHAR(100),
    suggested_by    BIGINT REFERENCES profiles(id) NOT NULL,
    status          VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    admin_comment   TEXT,
    reviewed_by     BIGINT REFERENCES profiles(id),
    reviewed_at     TIMESTAMP,
    created_at      TIMESTAMP DEFAULT NOW(),
    CONSTRAINT unique_pending_skill_name UNIQUE (name, status)
);

-- Indexes for performance
CREATE INDEX idx_skill_suggestions_status ON skill_suggestions(status);
CREATE INDEX idx_skill_suggestions_suggested_by ON skill_suggestions(suggested_by);
CREATE INDEX idx_skill_suggestions_created_at ON skill_suggestions(created_at DESC);

-- Create schema for skill management
CREATE SCHEMA IF NOT EXISTS skill_management;

-- Function: Suggest a new skill (for clients and freelancers)
CREATE OR REPLACE FUNCTION skill_management.suggest_skill(
    p_name VARCHAR(100),
    p_category VARCHAR(100),
    p_user_id BIGINT
)
RETURNS TABLE (
    suggestion_id BIGINT,
    skill_name VARCHAR(100),
    skill_category VARCHAR(100),
    status VARCHAR(20),
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_suggestion_id BIGINT;
    v_existing_skill_id INTEGER;
    v_pending_suggestion_id BIGINT;
BEGIN
    -- Check if skill already exists
    SELECT id INTO v_existing_skill_id
    FROM skills
    WHERE LOWER(name) = LOWER(p_name);
    
    IF v_existing_skill_id IS NOT NULL THEN
        RAISE EXCEPTION 'Skill "%" already exists with ID %', p_name, v_existing_skill_id;
    END IF;
    
    -- Check if there's already a pending suggestion with this name
    SELECT id INTO v_pending_suggestion_id
    FROM skill_suggestions
    WHERE LOWER(name) = LOWER(p_name)
      AND status = 'pending';
    
    IF v_pending_suggestion_id IS NOT NULL THEN
        RAISE EXCEPTION 'A suggestion for skill "%" is already pending approval', p_name;
    END IF;
    
    -- Create suggestion
    INSERT INTO skill_suggestions (name, category, suggested_by, status)
    VALUES (p_name, p_category, p_user_id, 'pending')
    RETURNING id INTO v_suggestion_id;
    
    RETURN QUERY
    SELECT 
        v_suggestion_id,
        p_name,
        p_category,
        'pending'::VARCHAR(20),
        'Skill suggestion submitted successfully. Waiting for admin approval.'::TEXT;
END;
$$;

-- Function: Get all skill suggestions (for admins)
CREATE OR REPLACE FUNCTION skill_management.get_skill_suggestions(
    p_admin_id BIGINT,
    p_status VARCHAR(20) DEFAULT NULL
)
RETURNS TABLE (
    suggestion_id BIGINT,
    skill_name VARCHAR(100),
    skill_category VARCHAR(100),
    status VARCHAR(20),
    suggested_by_id BIGINT,
    suggested_by_name TEXT,
    suggested_by_email VARCHAR(255),
    admin_comment TEXT,
    reviewed_by_id BIGINT,
    reviewed_by_name TEXT,
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_admin_role_id INTEGER;
BEGIN
    -- Verify user is admin
    SELECT a.role_id INTO v_admin_role_id
    FROM profiles p
    JOIN accounts a ON a.id = p.account_id
    WHERE p.id = p_admin_id;
    
    IF v_admin_role_id IS NULL OR v_admin_role_id != 3 THEN
        RAISE EXCEPTION 'Only administrators can view skill suggestions';
    END IF;
    
    RETURN QUERY
    SELECT 
        ss.id AS suggestion_id,
        ss.name AS skill_name,
        ss.category AS skill_category,
        ss.status,
        ss.suggested_by AS suggested_by_id,
        CONCAT(sp.first_name, ' ', sp.last_name) AS suggested_by_name,
        sa.email AS suggested_by_email,
        ss.admin_comment,
        ss.reviewed_by AS reviewed_by_id,
        CASE 
            WHEN ss.reviewed_by IS NOT NULL 
            THEN CONCAT(rp.first_name, ' ', rp.last_name)
            ELSE NULL
        END AS reviewed_by_name,
        ss.reviewed_at,
        ss.created_at
    FROM skill_suggestions ss
    JOIN profiles sp ON sp.id = ss.suggested_by
    JOIN accounts sa ON sa.id = sp.account_id
    LEFT JOIN profiles rp ON rp.id = ss.reviewed_by
    WHERE p_status IS NULL OR ss.status = p_status
    ORDER BY 
        CASE ss.status
            WHEN 'pending' THEN 1
            WHEN 'approved' THEN 2
            WHEN 'rejected' THEN 3
        END,
        ss.created_at DESC;
END;
$$;

-- Function: Get user's own skill suggestions
CREATE OR REPLACE FUNCTION skill_management.get_my_skill_suggestions(
    p_user_id BIGINT
)
RETURNS TABLE (
    suggestion_id BIGINT,
    skill_name VARCHAR(100),
    skill_category VARCHAR(100),
    status VARCHAR(20),
    admin_comment TEXT,
    reviewed_by_name TEXT,
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ss.id AS suggestion_id,
        ss.name AS skill_name,
        ss.category AS skill_category,
        ss.status,
        ss.admin_comment,
        CASE 
            WHEN ss.reviewed_by IS NOT NULL 
            THEN CONCAT(rp.first_name, ' ', rp.last_name)
            ELSE NULL
        END AS reviewed_by_name,
        ss.reviewed_at,
        ss.created_at
    FROM skill_suggestions ss
    LEFT JOIN profiles rp ON rp.id = ss.reviewed_by
    WHERE ss.suggested_by = p_user_id
    ORDER BY ss.created_at DESC;
END;
$$;

-- Function: Approve skill suggestion (for admins)
CREATE OR REPLACE FUNCTION skill_management.approve_skill_suggestion(
    p_suggestion_id BIGINT,
    p_admin_id BIGINT,
    p_admin_comment TEXT DEFAULT NULL
)
RETURNS TABLE (
    skill_id INTEGER,
    skill_name VARCHAR(100),
    skill_category VARCHAR(100),
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_admin_role_id INTEGER;
    v_suggestion_status VARCHAR(20);
    v_skill_name VARCHAR(100);
    v_skill_category VARCHAR(100);
    v_new_skill_id INTEGER;
BEGIN
    -- Verify user is admin
    SELECT a.role_id INTO v_admin_role_id
    FROM profiles p
    JOIN accounts a ON a.id = p.account_id
    WHERE p.id = p_admin_id;
    
    IF v_admin_role_id IS NULL OR v_admin_role_id != 3 THEN
        RAISE EXCEPTION 'Only administrators can approve skill suggestions';
    END IF;
    
    -- Get suggestion details
    SELECT status, name, category 
    INTO v_suggestion_status, v_skill_name, v_skill_category
    FROM skill_suggestions
    WHERE id = p_suggestion_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Skill suggestion % not found', p_suggestion_id;
    END IF;
    
    IF v_suggestion_status != 'pending' THEN
        RAISE EXCEPTION 'Skill suggestion has already been % ', v_suggestion_status;
    END IF;
    
    -- Create the skill
    INSERT INTO skills (name, category)
    VALUES (v_skill_name, v_skill_category)
    RETURNING id INTO v_new_skill_id;
    
    -- Update suggestion status
    UPDATE skill_suggestions
    SET status = 'approved',
        reviewed_by = p_admin_id,
        reviewed_at = NOW(),
        admin_comment = p_admin_comment
    WHERE id = p_suggestion_id;
    
    RETURN QUERY
    SELECT 
        v_new_skill_id,
        v_skill_name,
        v_skill_category,
        'Skill suggestion approved and added to the system'::TEXT;
END;
$$;

-- Function: Reject skill suggestion (for admins)
CREATE OR REPLACE FUNCTION skill_management.reject_skill_suggestion(
    p_suggestion_id BIGINT,
    p_admin_id BIGINT,
    p_admin_comment TEXT
)
RETURNS TABLE (
    suggestion_id BIGINT,
    skill_name VARCHAR(100),
    status VARCHAR(20),
    message TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_admin_role_id INTEGER;
    v_suggestion_status VARCHAR(20);
    v_skill_name VARCHAR(100);
BEGIN
    -- Verify user is admin
    SELECT a.role_id INTO v_admin_role_id
    FROM profiles p
    JOIN accounts a ON a.id = p.account_id
    WHERE p.id = p_admin_id;
    
    IF v_admin_role_id IS NULL OR v_admin_role_id != 3 THEN
        RAISE EXCEPTION 'Only administrators can reject skill suggestions';
    END IF;
    
    -- Get suggestion details
    SELECT status, name 
    INTO v_suggestion_status, v_skill_name
    FROM skill_suggestions
    WHERE id = p_suggestion_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Skill suggestion % not found', p_suggestion_id;
    END IF;
    
    IF v_suggestion_status != 'pending' THEN
        RAISE EXCEPTION 'Skill suggestion has already been %', v_suggestion_status;
    END IF;
    
    IF p_admin_comment IS NULL OR TRIM(p_admin_comment) = '' THEN
        RAISE EXCEPTION 'Admin comment is required when rejecting a suggestion';
    END IF;
    
    -- Update suggestion status
    UPDATE skill_suggestions
    SET status = 'rejected',
        reviewed_by = p_admin_id,
        reviewed_at = NOW(),
        admin_comment = p_admin_comment
    WHERE id = p_suggestion_id;
    
    RETURN QUERY
    SELECT 
        p_suggestion_id,
        v_skill_name,
        'rejected'::VARCHAR(20),
        'Skill suggestion rejected'::TEXT;
END;
$$;

-- Function: Get skill suggestion statistics (for admins)
CREATE OR REPLACE FUNCTION skill_management.get_suggestion_statistics(
    p_admin_id BIGINT
)
RETURNS TABLE (
    total_suggestions BIGINT,
    pending_suggestions BIGINT,
    approved_suggestions BIGINT,
    rejected_suggestions BIGINT,
    suggestions_today BIGINT,
    suggestions_this_week BIGINT,
    suggestions_this_month BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_admin_role_id INTEGER;
BEGIN
    -- Verify user is admin
    SELECT a.role_id INTO v_admin_role_id
    FROM profiles p
    JOIN accounts a ON a.id = p.account_id
    WHERE p.id = p_admin_id;
    
    IF v_admin_role_id IS NULL OR v_admin_role_id != 3 THEN
        RAISE EXCEPTION 'Only administrators can view statistics';
    END IF;
    
    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT AS total_suggestions,
        COUNT(*) FILTER (WHERE status = 'pending')::BIGINT AS pending_suggestions,
        COUNT(*) FILTER (WHERE status = 'approved')::BIGINT AS approved_suggestions,
        COUNT(*) FILTER (WHERE status = 'rejected')::BIGINT AS rejected_suggestions,
        COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE)::BIGINT AS suggestions_today,
        COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days')::BIGINT AS suggestions_this_week,
        COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '30 days')::BIGINT AS suggestions_this_month
    FROM skill_suggestions;
END;
$$;

-- Comments
COMMENT ON TABLE skill_suggestions IS 'Skill suggestions from users awaiting admin approval';
COMMENT ON COLUMN skill_suggestions.status IS 'Status: pending, approved, rejected';
COMMENT ON FUNCTION skill_management.suggest_skill IS 'Users can suggest new skills for admin approval';
COMMENT ON FUNCTION skill_management.get_skill_suggestions IS 'Admins can view all skill suggestions';
COMMENT ON FUNCTION skill_management.get_my_skill_suggestions IS 'Users can view their own skill suggestions';
COMMENT ON FUNCTION skill_management.approve_skill_suggestion IS 'Admins can approve skill suggestions';
COMMENT ON FUNCTION skill_management.reject_skill_suggestion IS 'Admins can reject skill suggestions with comment';
COMMENT ON FUNCTION skill_management.get_suggestion_statistics IS 'Get statistics about skill suggestions';
