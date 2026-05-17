CREATE OR REPLACE FUNCTION profile_management.get_profile_id_by_email(
    p_email VARCHAR
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_profile_id BIGINT;
BEGIN
    SELECT p.id
    INTO v_profile_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_email;

    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Profile for user % not found', p_email;
    END IF;

    RETURN v_profile_id;
END;
$$;

CREATE OR REPLACE FUNCTION profile_management.get_my_skills(
    p_email VARCHAR
)
RETURNS TABLE(
    skill_id INTEGER,
    skill_name VARCHAR,
    skill_category VARCHAR,
    skill_level VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_profile_id BIGINT;
BEGIN
    v_profile_id := profile_management.get_profile_id_by_email(p_email);

    RETURN QUERY
    SELECT s.id,
           s.name,
           s.category,
           ps.skill_level
    FROM profile_skills ps
    JOIN skills s ON s.id = ps.skill_id
    WHERE ps.profile_id = v_profile_id
    ORDER BY s.category, s.name;
END;
$$;

CREATE OR REPLACE FUNCTION profile_management.get_my_available_skills(
    p_email VARCHAR
)
RETURNS TABLE(
    skill_id INTEGER,
    skill_name VARCHAR,
    skill_category VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_profile_id BIGINT;
BEGIN
    v_profile_id := profile_management.get_profile_id_by_email(p_email);

    RETURN QUERY
    SELECT s.id,
           s.name,
           s.category
    FROM skills s
    WHERE NOT EXISTS (
        SELECT 1
        FROM profile_skills ps
        WHERE ps.profile_id = v_profile_id
          AND ps.skill_id = s.id
    )
    ORDER BY s.category, s.name;
END;
$$;

CREATE OR REPLACE PROCEDURE profile_management.upsert_my_skill(
    p_email VARCHAR,
    p_skill_id INTEGER,
    p_skill_level VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_profile_id BIGINT;
    v_level VARCHAR;
BEGIN
    v_profile_id := profile_management.get_profile_id_by_email(p_email);
    v_level := UPPER(BTRIM(p_skill_level));

    IF p_skill_id IS NULL THEN
        RAISE EXCEPTION 'Skill id is required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM skills WHERE id = p_skill_id) THEN
        RAISE EXCEPTION 'Skill % not found', p_skill_id;
    END IF;

    IF v_level IS NULL OR v_level = '' THEN
        RAISE EXCEPTION 'Skill level is required';
    END IF;

    IF v_level NOT IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') THEN
        RAISE EXCEPTION 'Unsupported skill level %. Allowed: BEGINNER, INTERMEDIATE, ADVANCED, EXPERT', v_level;
    END IF;

    INSERT INTO profile_skills(profile_id, skill_id, skill_level)
    VALUES (v_profile_id, p_skill_id, v_level)
    ON CONFLICT (profile_id, skill_id)
        DO UPDATE SET skill_level = EXCLUDED.skill_level;
END;
$$;

CREATE OR REPLACE PROCEDURE profile_management.delete_my_skill(
    p_email VARCHAR,
    p_skill_id INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_profile_id BIGINT;
BEGIN
    v_profile_id := profile_management.get_profile_id_by_email(p_email);

    IF NOT EXISTS (
        SELECT 1
        FROM profile_skills
        WHERE profile_id = v_profile_id
          AND skill_id = p_skill_id
    ) THEN
        RAISE EXCEPTION 'Skill % is not assigned to your profile', p_skill_id;
    END IF;

    DELETE FROM profile_skills
    WHERE profile_id = v_profile_id
      AND skill_id = p_skill_id;
END;
$$;
