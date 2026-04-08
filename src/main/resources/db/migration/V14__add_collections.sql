-- -----------------------------------------------------------------------------
-- 3. get_jobs_by_skill_ids(skill_ids[])
--    Returns all OPEN jobs that require ALL of the given skills (strict match).
--    Useful for skill-based job alerts.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION job_management.get_jobs_by_skill_ids(
    p_skill_ids INTEGER[]
)
    RETURNS TABLE (
                      job_id      BIGINT,
                      title       VARCHAR(255),
                      min_budget  DECIMAL(15,2),
                      max_budget  DECIMAL(15,2),
                      created_at  TIMESTAMP
                  )
    LANGUAGE plpgsql AS $$
DECLARE
    v_skill_count INT;
BEGIN
    IF p_skill_ids IS NULL OR array_length(p_skill_ids, 1) IS NULL THEN
        RAISE EXCEPTION 'skill_ids array must not be empty.';
    END IF;

    v_skill_count := array_length(p_skill_ids, 1);

    RETURN QUERY
        SELECT  j.id,
                j.title,
                j.min_budget,
                j.max_budget,
                j.created_at
        FROM    jobs j
                    JOIN    job_statuses js ON js.id = j.status_id
        WHERE   js.status_name = 'OPEN'
          AND   (
                    SELECT COUNT(*)
                    FROM   job_required_skills jrs
                    WHERE  jrs.job_id   = j.id
                      AND  jrs.skill_id = ANY(p_skill_ids)
                ) = v_skill_count
        ORDER BY j.created_at DESC;
END;
$$;


-- -----------------------------------------------------------------------------
-- 4. get_freelancers_by_skill_ids(skill_ids[])
--    Returns all freelancer profiles that have ALL of the given skills.
--    Useful for client-side "find talent" search.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION job_management.get_freelancers_by_skill_ids(
    p_skill_ids INTEGER[]
)
    RETURNS TABLE (
                      profile_id  BIGINT,
                      full_name   TEXT,
                      hourly_rate DECIMAL(10,2),
                      email       VARCHAR(255)
                  )
    LANGUAGE plpgsql AS $$
DECLARE
    v_skill_count INT;
BEGIN
    IF p_skill_ids IS NULL OR array_length(p_skill_ids, 1) IS NULL THEN
        RAISE EXCEPTION 'skill_ids array must not be empty.';
    END IF;

    SELECT COUNT(DISTINCT s)
    INTO v_skill_count
    FROM unnest(p_skill_ids) AS s;

    RETURN QUERY
        SELECT  p.id,
                (p.first_name || ' ' || p.last_name)::TEXT,
                p.hourly_rate,
                a.email
        FROM    profiles p
                    JOIN    accounts  a  ON a.id = p.account_id
                    JOIN    profile_skills ps ON ps.profile_id = p.id
        WHERE   a.role_id  = 2                  -- freelancers only
          AND   ps.skill_id = ANY(p_skill_ids)
        GROUP BY p.id, p.first_name, p.last_name, p.hourly_rate, a.email
        HAVING  COUNT(DISTINCT ps.skill_id) = v_skill_count
        ORDER BY p.hourly_rate ASC NULLS LAST;
END;
$$;


-- -----------------------------------------------------------------------------
-- 5. get_contract_history(profile_id)
--    Returns the full contract history for a freelancer as a JSONB array.
--    Each element contains the job title, status, amount, and skill list.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION job_management.get_contract_history(
    p_profile_id BIGINT
)
    RETURNS JSONB
    LANGUAGE plpgsql AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(
                   JSONB_AGG(
                           JSONB_BUILD_OBJECT(
                                   'contractId',   c.id,
                                   'jobTitle',     j.title,
                                   'status',       c.status,
                                   'totalAmount',  c.total_amount,
                                   'skills',       (
                                       SELECT ARRAY_AGG(s.name)
                                       FROM   job_required_skills jrs
                                                  JOIN   skills s ON s.id = jrs.skill_id
                                       WHERE  jrs.job_id = j.id
                                   )
                           )
                           ORDER BY c.id DESC
                   ),
                   '[]'::JSONB
           )
    INTO v_result
    FROM  contracts c
              JOIN  jobs      j ON j.id = c.job_id
    WHERE c.freelancer_id = p_profile_id;

    RETURN v_result;
END;
$$;
