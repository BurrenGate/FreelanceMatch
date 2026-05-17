CREATE SCHEMA IF NOT EXISTS job_management;

CREATE OR REPLACE FUNCTION job_management.get_recommended_jobs(p_email VARCHAR(255))
    RETURNS TABLE (
                      id BIGINT,
                      client_id BIGINT,
                      title VARCHAR(255),
                      description TEXT,
                      budget_type VARCHAR(50),
                      min_budget DECIMAL(15,2),
                      max_budget DECIMAL(15,2),
                      status_name VARCHAR(50),
                      created_at TIMESTAMP,
                      match_percentage NUMERIC
                  )
    LANGUAGE plpgsql
AS $$
DECLARE
    v_freelancer_id BIGINT;
BEGIN
    -- 1. Находим ID профиля фрилансера по email
    SELECT p.id INTO v_freelancer_id
    FROM accounts a
             JOIN profiles p ON a.id = p.account_id
    WHERE a.email = p_email;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Freelancer profile not found for email: %', p_email;
    END IF;

    -- 2. Возвращаем запрос, который высчитывает релевантность
    RETURN QUERY
        WITH JobSkillCounts AS (
            -- Считаем, сколько всего навыков требует каждый заказ
            SELECT job_id, COUNT(skill_id) AS total_req
            FROM job_required_skills
            GROUP BY job_id
        ),
             MatchedSkills AS (
                 -- Считаем, сколько требуемых навыков ЕСТЬ у данного фрилансера
                 SELECT jrs.job_id, COUNT(ps.skill_id) AS matched_req
                 FROM job_required_skills jrs
                          JOIN profile_skills ps ON ps.skill_id = jrs.skill_id
                 WHERE ps.profile_id = v_freelancer_id
                 GROUP BY jrs.job_id
             )
        SELECT
            j.id,
            j.client_id,
            j.title,
            j.description,
            j.budget_type,
            j.min_budget,
            j.max_budget,
            js.status_name,
            j.created_at,
            -- Высчитываем процент. NULLIF защищает от деления на ноль
            ROUND(COALESCE(m.matched_req, 0) * 100.0 / NULLIF(c.total_req, 0), 2) AS match_percentage
        FROM jobs j
                 JOIN job_statuses js ON j.status_id = js.id
                 JOIN JobSkillCounts c ON j.id = c.job_id -- Берем только работы, где есть требования к навыкам
                 LEFT JOIN MatchedSkills m ON j.id = m.job_id
        WHERE js.status_name = 'OPEN' -- Только открытые вакансии
          AND ROUND(COALESCE(m.matched_req, 0) * 100.0 / NULLIF(c.total_req, 0), 2) >= 50.00 -- Отсекаем все, что меньше 50%
        ORDER BY match_percentage DESC, j.created_at DESC; -- Сортируем: сначала 100% совпадения, потом новые
END;
$$;