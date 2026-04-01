-- 1. Создаем отдельную схему для управления профилями, как указано в твоем Java-коде
CREATE SCHEMA IF NOT EXISTS profile_management;

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