CREATE SCHEMA IF NOT EXISTS user_management;
CREATE SCHEMA IF NOT EXISTS job_market;

CREATE OR REPLACE PROCEDURE user_management.register_user(
    p_email         VARCHAR(255),
    p_password_hash VARCHAR(255),
    p_role_id       INTEGER,
    p_first_name    VARCHAR(100),
    p_last_name     VARCHAR(100),
    p_hourly_rate   DECIMAL(10,2)
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_new_account_id BIGINT;
BEGIN
    INSERT INTO accounts (email, password_hash, role_id)
    VALUES (p_email, p_password_hash, p_role_id)
    RETURNING id INTO v_new_account_id;

    INSERT INTO profiles (account_id, first_name, last_name, hourly_rate)
    VALUES (v_new_account_id, p_first_name, p_last_name, p_hourly_rate);

    RAISE NOTICE 'User % registered successfully. Account ID: %', p_email, v_new_account_id;

EXCEPTION
    WHEN unique_violation THEN
        IF SQLERRM ILIKE '%email%' THEN
            RAISE EXCEPTION 'Account with email "%" already exists.', p_email;
        ELSE
            RAISE EXCEPTION 'DB unique violation (possible ID out of sync): %', SQLERRM;
        END IF;

    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error registering user %. Details: %', p_email, SQLERRM;
END;
$$;

CREATE OR REPLACE FUNCTION job_market.get_freelancer_rating(p_profile_id BIGINT)
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

CREATE OR REPLACE FUNCTION job_market.get_freelancer_total_earnings(p_profile_id BIGINT)
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

CREATE OR REPLACE FUNCTION job_market.get_active_jobs_count(p_profile_id BIGINT)
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

CREATE OR REPLACE FUNCTION job_market.is_freelancer_available(p_profile_id BIGINT)
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

CREATE OR REPLACE PROCEDURE job_market.get_recommended_freelancers(p_job_id BIGINT)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_total_required    INT;
BEGIN
    DROP TABLE IF EXISTS temp_recommended_freelancers;
    CREATE TEMP TABLE temp_recommended_freelancers (
        profile_id   BIGINT,
        full_name    VARCHAR(200),
        hourly_rate  DECIMAL(10,2),
        email        VARCHAR(255),
        match_pct    NUMERIC(5,2)
    );

    SELECT COUNT(*) INTO v_total_required
    FROM   job_required_skills
    WHERE  job_id = p_job_id;

    IF v_total_required = 0 THEN
        RETURN;
    END IF;

    INSERT INTO temp_recommended_freelancers (profile_id, full_name, hourly_rate, email, match_pct)
    SELECT p.id,
           p.first_name || ' ' || p.last_name,
           p.hourly_rate,
           a.email,
           ROUND((COUNT(ps.skill_id)::NUMERIC / v_total_required) * 100, 2) as match_pct
    FROM profiles p
    JOIN accounts a ON a.id = p.account_id
    JOIN profile_skills ps ON ps.profile_id = p.id
    JOIN job_required_skills jrs ON jrs.skill_id = ps.skill_id
    WHERE a.role_id = 2 AND jrs.job_id = p_job_id
    GROUP BY p.id, a.email
    HAVING (COUNT(ps.skill_id)::NUMERIC / v_total_required) * 100 >= 50;

END;
$$;

CREATE OR REPLACE PROCEDURE job_market.submit_proposal(
    p_job_id        BIGINT,
    p_freelancer_id BIGINT,
    p_bid_amount    DECIMAL(15,2),
    p_cover_letter  TEXT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_job_status_id INTEGER;
BEGIN
    SELECT status_id INTO v_job_status_id FROM jobs WHERE id = p_job_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Job ID % not found.', p_job_id;
    END IF;

    IF v_job_status_id <> 1 THEN
        RAISE EXCEPTION 'Cannot submit proposal. Job is not open.';
    END IF;

    IF EXISTS (SELECT 1 FROM proposals WHERE job_id = p_job_id AND freelancer_id = p_freelancer_id) THEN
        RAISE EXCEPTION 'Freelancer % has already applied to job %.', p_freelancer_id, p_job_id;
    END IF;

    INSERT INTO proposals (job_id, freelancer_id, bid_amount, cover_letter, status)
    VALUES (p_job_id, p_freelancer_id, p_bid_amount, p_cover_letter, 'pending');
END;
$$;

CREATE OR REPLACE PROCEDURE job_market.finalize_proposal_and_create_contract(p_proposal_id BIGINT)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_proposal_status  VARCHAR(50);
    v_job_id           BIGINT;
    v_freelancer_id    BIGINT;
    v_bid_amount       DECIMAL(15,2);
BEGIN
    SELECT status, job_id, freelancer_id, bid_amount
    INTO   v_proposal_status, v_job_id, v_freelancer_id, v_bid_amount
    FROM   proposals
    WHERE  id = p_proposal_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Proposal % does not exist.', p_proposal_id;
    END IF;

    IF v_proposal_status <> 'pending' THEN
        RAISE EXCEPTION 'Proposal % cannot be accepted.', p_proposal_id;
    END IF;

    INSERT INTO contracts (job_id, freelancer_id, total_amount, status)
    VALUES (v_job_id, v_freelancer_id, v_bid_amount, 'active');
END;
$$;

CREATE OR REPLACE PROCEDURE job_market.complete_job_and_rate(
    p_contract_id BIGINT,
    p_rating      NUMERIC,
    p_feedback    TEXT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_contract_status VARCHAR(50);
    v_job_id          BIGINT;
    v_total_amount    DECIMAL(15,2);
    v_client_id       BIGINT;
    v_int_rating      INTEGER;
BEGIN
    v_int_rating := ROUND(p_rating);

    SELECT status, job_id, total_amount
    INTO v_contract_status, v_job_id, v_total_amount
    FROM contracts
    WHERE id = p_contract_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract % not found.', p_contract_id;
    END IF;

    IF v_contract_status <> 'active' THEN
        RAISE EXCEPTION 'Contract % is not active.', p_contract_id;
    END IF;

    SELECT client_id INTO v_client_id FROM jobs WHERE id = v_job_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Job with ID % associated with contract % not found.', v_job_id, p_contract_id;
    END IF;

    UPDATE contracts SET status = 'completed' WHERE id = p_contract_id;
    UPDATE jobs SET status_id = 3 WHERE id = v_job_id;

    INSERT INTO transactions (contract_id, amount, type)
    VALUES (p_contract_id, v_total_amount, 'payment');

    INSERT INTO reviews (contract_id, reviewer_id, rating, comment)
    VALUES (p_contract_id, v_client_id, v_int_rating, p_feedback);
END;
$$;

CREATE OR REPLACE FUNCTION job_market.get_skill_match_count(p_job_id BIGINT, p_profile_id BIGINT)
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

CREATE OR REPLACE FUNCTION job_market.get_last_transaction_amount(p_contract_id BIGINT)
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
