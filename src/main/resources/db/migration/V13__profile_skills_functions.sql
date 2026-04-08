CREATE OR REPLACE FUNCTION get_profile_skills(p_profile_id BIGINT)
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
            s.id AS skill_id,
            s.name AS skill_name,
            s.category AS skill_category,
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

-- ==============================================================================
-- Функция 2: Получение полного списка навыков для выбора при заполнении профиля
-- ==============================================================================
CREATE OR REPLACE FUNCTION get_all_available_skills()
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
            s.id AS skill_id,
            s.name AS skill_name,
            s.category AS skill_category
        FROM
            skills s
        ORDER BY
            s.category, s.name;
END;
$$;

-- ==============================================================================
-- Опционально: Функция для получения списка навыков, которых ЕЩЕ НЕТ у профиля
-- (Удобно для UI, чтобы не предлагать добавить навык, который уже добавлен)
-- ==============================================================================
CREATE OR REPLACE FUNCTION get_available_skills_for_profile(p_profile_id BIGINT)
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
            s.id AS skill_id,
            s.name AS skill_name,
            s.category AS skill_category
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