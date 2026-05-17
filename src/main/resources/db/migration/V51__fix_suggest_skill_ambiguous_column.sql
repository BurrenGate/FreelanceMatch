-- V51: Fix ambiguous column reference in suggest_skill function

DROP FUNCTION IF EXISTS skill_management.suggest_skill(VARCHAR, VARCHAR, BIGINT);

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
    SELECT ss.id INTO v_pending_suggestion_id
    FROM skill_suggestions ss
    WHERE LOWER(ss.name) = LOWER(p_name)
      AND ss.status = 'pending';
    
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
