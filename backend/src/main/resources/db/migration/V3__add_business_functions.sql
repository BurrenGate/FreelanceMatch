CREATE OR REPLACE FUNCTION get_freelancer_rating(p_profile_id BIGINT)
RETURNS NUMERIC(3,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_rating NUMERIC(3,2);
BEGIN
    SELECT AVG(rating) INTO v_rating
    FROM   reviews
    WHERE  reviewer_id <> p_profile_id
      AND  contract_id IN (SELECT id FROM contracts WHERE freelancer_id = p_profile_id);
    
    RETURN COALESCE(v_rating, 0.00);
END;
$$;

CREATE OR REPLACE FUNCTION get_freelancer_total_earnings(p_profile_id BIGINT)
RETURNS DECIMAL(15,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_total DECIMAL(15,2);
BEGIN
    SELECT SUM(total_amount) INTO v_total
    FROM   contracts
    WHERE  freelancer_id = p_profile_id
      AND  status = 'completed';
    
    RETURN COALESCE(v_total, 0.00);
END;
$$;

CREATE OR REPLACE FUNCTION get_active_jobs_count(p_profile_id BIGINT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT (
        (SELECT COUNT(*) FROM jobs WHERE client_id = p_profile_id AND status_id IN (1, 2))
        +
        (SELECT COUNT(*) FROM contracts WHERE freelancer_id = p_profile_id AND status = 'active')
    ) INTO v_count;
    
    RETURN v_count;
END;
$$;

CREATE OR REPLACE FUNCTION get_skill_match_count(p_job_id BIGINT, p_profile_id BIGINT)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM   job_required_skills jrs
    JOIN   profile_skills ps ON ps.skill_id = jrs.skill_id
    WHERE  jrs.job_id = p_job_id
      AND  ps.profile_id = p_profile_id;
    
    RETURN v_count;
END;
$$;

CREATE OR REPLACE FUNCTION get_last_transaction_amount(p_contract_id BIGINT)
RETURNS DECIMAL(15,2)
LANGUAGE plpgsql
AS $$
DECLARE
    v_amount DECIMAL(15,2);
BEGIN
    SELECT amount INTO v_amount
    FROM   transactions
    WHERE  contract_id = p_contract_id
    ORDER  BY created_at DESC
    LIMIT  1;
    
    RETURN COALESCE(v_amount, 0.00);
END;
$$;

CREATE OR REPLACE FUNCTION is_freelancer_available(p_profile_id BIGINT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_active_contracts INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_active_contracts
    FROM   contracts
    WHERE  freelancer_id = p_profile_id
      AND  status = 'active';
    
    RETURN v_active_contracts < 3;
END;
$$;
