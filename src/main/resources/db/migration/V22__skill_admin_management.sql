CREATE OR REPLACE FUNCTION admin_management.get_skills(
    p_category VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    category VARCHAR
)
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

CREATE OR REPLACE FUNCTION admin_management.get_skill_by_id(
    p_skill_id INTEGER,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    category VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF NOT EXISTS (SELECT 1 FROM skills WHERE skills.id = p_skill_id) THEN
        RAISE EXCEPTION 'Skill % not found', p_skill_id;
    END IF;

    RETURN QUERY
    SELECT s.id, s.name, s.category
    FROM skills s
    WHERE s.id = p_skill_id;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.create_skill(
    p_name VARCHAR,
    p_category VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    category VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_name VARCHAR;
    v_category VARCHAR;
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    v_name := BTRIM(p_name);
    v_category := BTRIM(p_category);

    IF v_name IS NULL OR v_name = '' THEN
        RAISE EXCEPTION 'Skill name cannot be empty';
    END IF;

    IF v_category IS NULL OR v_category = '' THEN
        RAISE EXCEPTION 'Skill category cannot be empty';
    END IF;

    IF EXISTS (SELECT 1 FROM skills WHERE LOWER(skills.name) = LOWER(v_name)) THEN
        RAISE EXCEPTION 'Skill % already exists', v_name;
    END IF;

    RETURN QUERY
    INSERT INTO skills(name, category)
    VALUES (v_name, v_category)
    RETURNING skills.id, skills.name, skills.category;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.update_skill(
    p_skill_id INTEGER,
    p_name VARCHAR,
    p_category VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    category VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_name VARCHAR;
    v_category VARCHAR;
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF NOT EXISTS (SELECT 1 FROM skills WHERE skills.id = p_skill_id) THEN
        RAISE EXCEPTION 'Skill % not found', p_skill_id;
    END IF;

    v_name := BTRIM(p_name);
    v_category := BTRIM(p_category);

    IF v_name IS NULL OR v_name = '' THEN
        RAISE EXCEPTION 'Skill name cannot be empty';
    END IF;

    IF v_category IS NULL OR v_category = '' THEN
        RAISE EXCEPTION 'Skill category cannot be empty';
    END IF;

    IF EXISTS (
        SELECT 1
        FROM skills
        WHERE LOWER(skills.name) = LOWER(v_name)
          AND skills.id <> p_skill_id
    ) THEN
        RAISE EXCEPTION 'Skill % already exists', v_name;
    END IF;

    RETURN QUERY
    UPDATE skills
    SET name = v_name,
        category = v_category
    WHERE skills.id = p_skill_id
    RETURNING skills.id, skills.name, skills.category;
END;
$$;

CREATE OR REPLACE PROCEDURE admin_management.delete_skill(
    p_skill_id INTEGER,
    p_admin_email VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF NOT EXISTS (SELECT 1 FROM skills WHERE skills.id = p_skill_id) THEN
        RAISE EXCEPTION 'Skill % not found', p_skill_id;
    END IF;

    IF EXISTS (SELECT 1 FROM profile_skills WHERE profile_skills.skill_id = p_skill_id)
       OR EXISTS (SELECT 1 FROM job_required_skills WHERE job_required_skills.skill_id = p_skill_id) THEN
        RAISE EXCEPTION 'Skill % is already used and cannot be deleted', p_skill_id;
    END IF;

    DELETE FROM skills WHERE skills.id = p_skill_id;
END;
$$;
