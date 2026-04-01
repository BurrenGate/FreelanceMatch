CREATE OR REPLACE PROCEDURE register_user(
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
    -- 1. Create account and capture the generated ID
    INSERT INTO accounts (email, password_hash, role_id)
    VALUES (p_email, p_password_hash, p_role_id)
    RETURNING id INTO v_new_account_id;

    -- 2. Create profile, linking it to the new account
    INSERT INTO profiles (account_id, first_name, last_name, hourly_rate)
    VALUES (v_new_account_id, p_first_name, p_last_name, p_hourly_rate);

    -- Log successful creation (visible in PostgreSQL console)
    RAISE NOTICE 'User % successfully registered. Account ID: %', p_email, v_new_account_id;

EXCEPTION
    -- Catch email duplicate error (UNIQUE constraint on accounts.email)
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Account with email "%" already exists.', p_email;

    -- Catch any other errors and roll back transaction
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error during user registration %. Details: %', p_email, SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE submit_proposal(
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
    -- 1. Check job status (only OPEN, id = 1 is allowed)
    SELECT status_id INTO v_job_status_id
    FROM jobs
    WHERE id = p_job_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Job with ID % not found.', p_job_id;
    END IF;

    IF v_job_status_id <> 1 THEN
        RAISE EXCEPTION 'Cannot submit proposal. Job is no longer open (current status_id: %).', v_job_status_id;
    END IF;

    -- 2. Protection against duplicate applications (business logic at DB level)
    IF EXISTS (SELECT 1 FROM proposals WHERE job_id = p_job_id AND freelancer_id = p_freelancer_id) THEN
        RAISE EXCEPTION 'Freelancer % already applied for job %.', p_freelancer_id, p_job_id;
    END IF;

    -- 3. Create proposal
    INSERT INTO proposals (job_id, freelancer_id, bid_amount, cover_letter, status)
    VALUES (p_job_id, p_freelancer_id, p_bid_amount, p_cover_letter, 'pending');

    RAISE NOTICE 'Proposal from freelancer % for job % successfully submitted.', p_freelancer_id, p_job_id;
END;
$$;


CREATE OR REPLACE PROCEDURE complete_job_and_rate(
    p_contract_id BIGINT,
    p_rating      NUMERIC, -- Accept NUMERIC, as BigDecimal comes from Java
    p_feedback    TEXT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_contract_status VARCHAR(50);
    v_job_id          BIGINT;
    v_freelancer_id   BIGINT;
    v_total_amount    DECIMAL(15,2);
    v_client_id       BIGINT;
    v_int_rating      INTEGER;
BEGIN
    -- Convert rating to integer and validate (DB constraint: 1-5)
    v_int_rating := ROUND(p_rating);

    IF v_int_rating < 1 OR v_int_rating > 5 THEN
        RAISE EXCEPTION 'Rating must be between 1 and 5, received: %', v_int_rating;
    END IF;

    -- 1. Get contract data
    SELECT status, job_id, freelancer_id, total_amount
    INTO v_contract_status, v_job_id, v_freelancer_id, v_total_amount
    FROM contracts
    WHERE id = p_contract_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract % not found.', p_contract_id;
    END IF;

    IF v_contract_status <> 'active' THEN
        RAISE EXCEPTION 'Contract % is not active (current status: %). Completion impossible.', p_contract_id, v_contract_status;
    END IF;

    -- Get client ID from jobs table (will be the review author)
    SELECT client_id INTO v_client_id FROM jobs WHERE id = v_job_id;

    -- 2. Close contract
    UPDATE contracts SET status = 'completed' WHERE id = p_contract_id;

    -- 3. Move job to COMPLETED status (id = 3)
    UPDATE jobs SET status_id = 3 WHERE id = v_job_id;

    -- 4. Process transaction (payment)
    INSERT INTO transactions (contract_id, amount, type)
    VALUES (p_contract_id, v_total_amount, 'payment');

    -- 5. Leave feedback
    INSERT INTO reviews (contract_id, reviewer_id, rating, comment)
    VALUES (p_contract_id, v_client_id, v_int_rating, p_feedback);

    RAISE NOTICE 'Contract % successfully completed. Transaction for amount % processed. Rating: %',
        p_contract_id, v_total_amount, v_int_rating;

EXCEPTION
    -- If any step fails, everything rolls back (atomicity!)
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error during contract completion %. Details: %', p_contract_id, SQLERRM;
END;
$$;
