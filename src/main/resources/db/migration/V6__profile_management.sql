-- V6: This script provides a comprehensive set of functions and procedures for managing user profiles,
-- including skills, profile data, and triggers for automatic timestamp updates.

CREATE SCHEMA IF NOT EXISTS profile_management;

-- Procedure to add or update a skill for a given profile.
-- If the skill already exists for the profile, it updates the skill level.
CREATE OR REPLACE PROCEDURE profile_management.add_skill(
    p_profile_id  BIGINT,
    p_skill_id    INTEGER,
    p_skill_level VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO profile_skills (profile_id, skill_id, skill_level)
    VALUES (p_profile_id, p_skill_id, p_skill_level)
    ON CONFLICT (profile_id, skill_id)
    DO UPDATE SET
        skill_level = EXCLUDED.skill_level;
END;
$$;
COMMENT ON PROCEDURE profile_management.add_skill(BIGINT, INTEGER, VARCHAR)
IS 'Adds a new skill to a profile or updates the level of an existing skill.';

-- Procedure to update a user's profile information.
-- If a profile does not exist, it creates one.
CREATE OR REPLACE PROCEDURE profile_management.update_profile(
    p_email         VARCHAR(255),
    p_first_name    VARCHAR(100),
    p_last_name     VARCHAR(100),
    p_bio           TEXT,
    p_hourly_rate   DECIMAL(10,2),
    p_avatar_url    VARCHAR(1000)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_account_id BIGINT;
BEGIN
    -- Find the account_id for the given email.
    SELECT id INTO v_account_id FROM accounts WHERE email = p_email;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account with email % not found', p_email;
    END IF;

    -- Update the profile data.
    UPDATE profiles
    SET first_name  = p_first_name,
        last_name   = p_last_name,
        bio         = p_bio,
        hourly_rate = p_hourly_rate,
        avatar_url  = p_avatar_url,
        updated_at  = NOW()
    WHERE account_id = v_account_id;

    -- If no profile was found to update, create a new one.
    IF NOT FOUND THEN
        INSERT INTO profiles (account_id, first_name, last_name, bio, hourly_rate, avatar_url)
        VALUES (v_account_id, p_first_name, p_last_name, p_bio, p_hourly_rate, p_avatar_url);
    END IF;
END;
$$;
COMMENT ON PROCEDURE profile_management.update_profile(VARCHAR, VARCHAR, VARCHAR, TEXT, DECIMAL, VARCHAR)
IS 'Updates a user''s profile information. Creates a profile if one does not already exist.';

-- Procedure to add multiple skills to a user's profile from a JSONB array.
CREATE OR REPLACE PROCEDURE profile_management.add_user_skills(
    p_email VARCHAR(255),
    p_skills_json JSONB
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_profile_id BIGINT;
BEGIN
    -- Find the profile_id for the given email.
    SELECT p.id INTO v_profile_id
    FROM accounts a
    JOIN profiles p ON a.id = p.account_id
    WHERE a.email = p_email;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Profile for user % not found', p_email;
    END IF;

    -- Parse the JSON array and insert or update skills.
    INSERT INTO profile_skills (profile_id, skill_id, skill_level)
    SELECT
        v_profile_id,
        (skill->>'skillId')::INTEGER,
        skill->>'skillLevel'
    FROM jsonb_array_elements(p_skills_json) AS skill
    ON CONFLICT (profile_id, skill_id)
    DO UPDATE SET
        skill_level = EXCLUDED.skill_level;
END;
$$;
COMMENT ON PROCEDURE profile_management.add_user_skills(VARCHAR, JSONB)
IS 'Adds or updates multiple skills for a user from a JSONB array of skill data.';

-- Function to get all skills for a specific profile.
CREATE OR REPLACE FUNCTION profile_management.get_profile_skills(p_profile_id BIGINT)
RETURNS TABLE (
    skill_id INTEGER,
    skill_name VARCHAR(100),
    skill_category VARCHAR(100),
    skill_level VARCHAR(50)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            s.id,
            s.name,
            s.category,
            ps.skill_level
        FROM
            profile_skills ps
        JOIN
            skills s ON ps.skill_id = s.id
        WHERE
            ps.profile_id = p_profile_id
        ORDER BY
            s.category, s.name;
END;
$$;
COMMENT ON FUNCTION profile_management.get_profile_skills(BIGINT)
IS 'Retrieves all skills associated with a given profile ID.';

-- Function to get all available skills in the system.
CREATE OR REPLACE FUNCTION profile_management.get_all_available_skills()
RETURNS TABLE (
    skill_id INTEGER,
    skill_name VARCHAR(100),
    skill_category VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            s.id,
            s.name,
            s.category
        FROM
            skills s
        ORDER BY
            s.category, s.name;
END;
$$;
COMMENT ON FUNCTION profile_management.get_all_available_skills()
IS 'Retrieves a list of all skills available in the system.';

-- Function to get all skills that are not yet associated with a specific profile.
CREATE OR REPLACE FUNCTION profile_management.get_available_skills_for_profile(p_profile_id BIGINT)
RETURNS TABLE (
    skill_id INTEGER,
    skill_name VARCHAR(100),
    skill_category VARCHAR(100)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
        SELECT
            s.id,
            s.name,
            s.category
        FROM
            skills s
        WHERE NOT EXISTS (
            SELECT 1
            FROM profile_skills ps
            WHERE ps.skill_id = s.id AND ps.profile_id = p_profile_id
        )
        ORDER BY
            s.category, s.name;
END;
$$;
COMMENT ON FUNCTION profile_management.get_available_skills_for_profile(BIGINT)
IS 'Retrieves skills that a specific profile has not yet added.';

-- Function to get the profile ID for a given email.
CREATE OR REPLACE FUNCTION profile_management.get_profile_id_by_email(p_email VARCHAR)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_profile_id BIGINT;
BEGIN
    SELECT p.id INTO v_profile_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE a.email = p_email;

    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Profile for user % not found', p_email;
    END IF;

    RETURN v_profile_id;
END;
$$;
COMMENT ON FUNCTION profile_management.get_profile_id_by_email(VARCHAR)
IS 'Resolves a profile ID from an account email.';

-- Function to get all skills for the currently authenticated user.
CREATE OR REPLACE FUNCTION profile_management.get_my_skills(p_email VARCHAR)
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
COMMENT ON FUNCTION profile_management.get_my_skills(VARCHAR)
IS 'Retrieves all skills for the user identified by the provided email.';

-- Function to get all available skills for the currently authenticated user.
CREATE OR REPLACE FUNCTION profile_management.get_my_available_skills(p_email VARCHAR)
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
COMMENT ON FUNCTION profile_management.get_my_available_skills(VARCHAR)
IS 'Retrieves all skills that the user identified by the email has not yet added to their profile.';

-- Procedure to add or update a skill for the currently authenticated user.
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
        RAISE EXCEPTION 'Skill ID is required.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM skills WHERE id = p_skill_id) THEN
        RAISE EXCEPTION 'Skill with ID % not found.', p_skill_id;
    END IF;

    IF v_level IS NULL OR v_level = '' THEN
        RAISE EXCEPTION 'Skill level is required.';
    END IF;

    IF v_level NOT IN ('BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT') THEN
        RAISE EXCEPTION 'Unsupported skill level: %. Allowed levels are: BEGINNER, INTERMEDIATE, ADVANCED, EXPERT.', v_level;
    END IF;

    INSERT INTO profile_skills(profile_id, skill_id, skill_level)
    VALUES (v_profile_id, p_skill_id, v_level)
    ON CONFLICT (profile_id, skill_id)
    DO UPDATE SET skill_level = EXCLUDED.skill_level;
END;
$$;
COMMENT ON PROCEDURE profile_management.upsert_my_skill(VARCHAR, INTEGER, VARCHAR)
IS 'Adds or updates a skill for the user identified by the email.';

-- Procedure to delete a skill from the currently authenticated user's profile.
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
        RAISE EXCEPTION 'Skill with ID % is not assigned to your profile.', p_skill_id;
    END IF;

    DELETE FROM profile_skills
    WHERE profile_id = v_profile_id
      AND skill_id = p_skill_id;
END;
$$;
COMMENT ON PROCEDURE profile_management.delete_my_skill(VARCHAR, INTEGER)
IS 'Deletes a skill from the profile of the user identified by the email.';

-- Trigger function to automatically update the 'updated_at' timestamp on profile changes.
CREATE OR REPLACE FUNCTION profile_management.trg_fn_profile_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;
COMMENT ON FUNCTION profile_management.trg_fn_profile_updated_at()
IS 'This trigger function automatically updates the updated_at timestamp whenever a profile is modified.';

-- Drop the trigger if it exists, then create it.
DROP TRIGGER IF EXISTS trg_profile_updated_at ON public.profiles;
CREATE TRIGGER trg_profile_updated_at
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION profile_management.trg_fn_profile_updated_at();
