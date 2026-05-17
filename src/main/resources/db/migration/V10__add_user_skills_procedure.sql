CREATE OR REPLACE PROCEDURE profile_management.add_user_skills(
    p_email VARCHAR(255),
    p_skills_json JSONB
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_profile_id BIGINT;
BEGIN
    -- 1. Находим profile_id, объединяя таблицы accounts и profiles
    SELECT p.id INTO v_profile_id
    FROM accounts a
             JOIN profiles p ON a.id = p.account_id
    WHERE a.email = p_email;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Profile for user % not found', p_email;
    END IF;

    -- 2. Парсим JSON-массив и массово вставляем навыки
    -- Используем ON CONFLICT для обновления уровня, если навык уже есть
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