-- ============================================================
-- FREELANCER PROJECT MATCHING PLATFORM
-- PostgreSQL DDL Schema + Advanced SQL Procedures
-- Database Systems 2 – University Project
-- ============================================================

-- ─── DROP TABLES (safe re-run) ───────────────────────────────
DROP TABLE IF EXISTS reviews      CASCADE;
DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS contracts    CASCADE;
DROP TABLE IF EXISTS proposals    CASCADE;
DROP TABLE IF EXISTS profile_skills CASCADE;
DROP TABLE IF EXISTS jobs         CASCADE;
DROP TABLE IF EXISTS job_statuses CASCADE;
DROP TABLE IF EXISTS profiles     CASCADE;
DROP TABLE IF EXISTS skills       CASCADE;
DROP TABLE IF EXISTS accounts     CASCADE;
DROP TABLE IF EXISTS roles        CASCADE;

-- ─── LOOKUP TABLES ───────────────────────────────────────────

CREATE TABLE roles (
                       id   INTEGER PRIMARY KEY,
                       name VARCHAR(50) NOT NULL
);

CREATE TABLE job_statuses (
                              id          INTEGER PRIMARY KEY,
                              status_name VARCHAR(50) NOT NULL
);

-- ─── ACCOUNTS & PROFILES ─────────────────────────────────────

CREATE TABLE accounts (
                          id            BIGSERIAL PRIMARY KEY,
                          email         VARCHAR(255) UNIQUE NOT NULL,
                          password_hash VARCHAR(255)        NOT NULL,
                          role_id       INTEGER REFERENCES roles(id),
                          status        VARCHAR(50)  DEFAULT 'active',
                          last_login    TIMESTAMP,
                          created_at    TIMESTAMP    DEFAULT NOW()
);

CREATE TABLE profiles (
                          id          BIGSERIAL PRIMARY KEY,
                          account_id  BIGINT REFERENCES accounts(id) ON DELETE CASCADE,
                          first_name  VARCHAR(100),
                          last_name   VARCHAR(100),
                          bio         TEXT,
                          hourly_rate DECIMAL(10,2),
                          avatar_url  VARCHAR(255),
                          updated_at  TIMESTAMP DEFAULT NOW()
);

-- ─── SKILLS ──────────────────────────────────────────────────

CREATE TABLE skills (
                        id       SERIAL PRIMARY KEY,
                        name     VARCHAR(100) UNIQUE NOT NULL,
                        category VARCHAR(100)
);

CREATE TABLE profile_skills (
                                profile_id  BIGINT  REFERENCES profiles(id) ON DELETE CASCADE,
                                skill_id    INTEGER REFERENCES skills(id)   ON DELETE CASCADE,
                                skill_level VARCHAR(50),
                                PRIMARY KEY (profile_id, skill_id)
);

-- ─── JOBS ────────────────────────────────────────────────────

CREATE TABLE jobs (
                      id          BIGSERIAL PRIMARY KEY,
                      client_id   BIGINT  REFERENCES profiles(id),
                      category_id INTEGER,
                      title       VARCHAR(255)   NOT NULL,
                      description TEXT,
                      budget_type VARCHAR(50),
                      min_budget  DECIMAL(15,2),
                      max_budget  DECIMAL(15,2),
                      status_id   INTEGER REFERENCES job_statuses(id),
                      created_at  TIMESTAMP DEFAULT NOW()
);

-- ─── PROPOSALS ───────────────────────────────────────────────

CREATE TABLE proposals (
                           id            BIGSERIAL PRIMARY KEY,
                           job_id        BIGINT REFERENCES jobs(id)     ON DELETE CASCADE,
                           freelancer_id BIGINT REFERENCES profiles(id),
                           bid_amount    DECIMAL(15,2),
                           delivery_days INTEGER,
                           cover_letter  TEXT,
                           status        VARCHAR(50) DEFAULT 'pending',
                           created_at    TIMESTAMP   DEFAULT NOW()
);

-- ─── FINANCIAL LAYER ─────────────────────────────────────────

CREATE TABLE contracts (
                           id            BIGSERIAL PRIMARY KEY,
                           job_id        BIGINT REFERENCES jobs(id),
                           freelancer_id BIGINT REFERENCES profiles(id),
                           total_amount  DECIMAL(15,2),
                           status        VARCHAR(50) DEFAULT 'active'
);

CREATE TABLE transactions (
                              id          BIGSERIAL PRIMARY KEY,
                              contract_id BIGINT REFERENCES contracts(id),
                              amount      DECIMAL(15,2),
                              type        VARCHAR(50),
                              created_at  TIMESTAMP DEFAULT NOW()
);

-- ─── REVIEWS ─────────────────────────────────────────────────

CREATE TABLE reviews (
                         id          BIGSERIAL PRIMARY KEY,
                         contract_id BIGINT REFERENCES contracts(id),
                         reviewer_id BIGINT REFERENCES profiles(id),
                         rating      INTEGER CHECK (rating BETWEEN 1 AND 5),
                         comment     TEXT
);

-- ─── SEED LOOKUP DATA ────────────────────────────────────────

INSERT INTO roles (id, name) VALUES
                                 (1, 'client'),
                                 (2, 'freelancer'),
                                 (3, 'admin');

INSERT INTO job_statuses (id, status_name) VALUES
                                               (1, 'OPEN'),
                                               (2, 'IN_PROGRESS'),
                                               (3, 'COMPLETED'),
                                               (4, 'CANCELLED');

-- ─── HELPER: link job → required skills via job_required_skills ──
-- We add a lightweight junction table so the matching procedure
-- knows which skills a job actually requires.

CREATE TABLE job_required_skills (
                                     job_id   BIGINT  REFERENCES jobs(id)   ON DELETE CASCADE,
                                     skill_id INTEGER REFERENCES skills(id) ON DELETE CASCADE,
                                     PRIMARY KEY (job_id, skill_id)
);

-- ============================================================
-- REQUIREMENT A  –  CURSOR + LOOP
-- Procedure: get_recommended_freelancers(p_job_id)
--
-- CONCEPT SUMMARY (for exam explanation):
--   1. A CURSOR is declared to walk through every freelancer row.
--   2. A LOOP fetches one row at a time via FETCH.
--   3. Inside the loop a sub-query counts how many required
--      skills the current freelancer possesses (the 50% check).
--   4. Matching freelancers are collected in a temporary table
--      that the caller can SELECT from.
-- ============================================================

CREATE OR REPLACE PROCEDURE get_recommended_freelancers(p_job_id INT)
    LANGUAGE plpgsql
AS $$
DECLARE
    -- ① CURSOR DECLARATION: will iterate every freelancer profile
    freelancer_cursor CURSOR FOR
        SELECT p.id          AS profile_id,
               p.first_name,
               p.last_name,
               p.hourly_rate,
               a.email
        FROM   profiles p
                   JOIN   accounts a ON a.id = p.account_id
        WHERE  a.role_id = 2;   -- role_id 2 = freelancer

    rec                 RECORD;
    v_total_required    INT;
    v_matched_skills    INT;
    v_match_pct         NUMERIC;
BEGIN
    -- Prepare a temp table to hold results for this session
    DROP TABLE IF EXISTS temp_recommended_freelancers;
    CREATE TEMP TABLE temp_recommended_freelancers (
                                                       profile_id   BIGINT,
                                                       full_name    VARCHAR(200),
                                                       hourly_rate  DECIMAL(10,2),
                                                       email        VARCHAR(255),
                                                       match_pct    NUMERIC(5,2)
    );

    -- Count how many skills this job requires
    SELECT COUNT(*) INTO v_total_required
    FROM   job_required_skills
    WHERE  job_id = p_job_id;

    -- If job has no required skills, nothing to match
    IF v_total_required = 0 THEN
        RAISE NOTICE 'Job % has no required skills defined.', p_job_id;
        RETURN;
    END IF;

    -- ② OPEN CURSOR
    OPEN freelancer_cursor;

    -- ③ LOOP – fetch one freelancer per iteration
    LOOP
        FETCH freelancer_cursor INTO rec;
        EXIT WHEN NOT FOUND;   -- exit condition

        -- ④ INNER LOGIC: count how many required job skills this freelancer has
        SELECT COUNT(*) INTO v_matched_skills
        FROM   profile_skills ps
                   JOIN   job_required_skills jrs
                          ON ps.skill_id = jrs.skill_id
        WHERE  ps.profile_id = rec.profile_id
          AND  jrs.job_id    = p_job_id;

        -- ⑤ CONDITIONAL: only insert if ≥ 50 % match
        v_match_pct := (v_matched_skills::NUMERIC / v_total_required) * 100;

        IF v_match_pct >= 50 THEN
            INSERT INTO temp_recommended_freelancers
            VALUES (
                       rec.profile_id,
                       rec.first_name || ' ' || rec.last_name,
                       rec.hourly_rate,
                       rec.email,
                       ROUND(v_match_pct, 2)
                   );
        END IF;

    END LOOP;

    -- ⑥ CLOSE CURSOR
    CLOSE freelancer_cursor;

    -- Caller can now: SELECT * FROM temp_recommended_freelancers;
    RAISE NOTICE 'Recommended freelancers loaded into temp_recommended_freelancers.';
END;
$$;


-- ============================================================
-- REQUIREMENT B  –  NESTED BLOCKS + CONDITIONALS + EXCEPTION HANDLING
-- Procedure: finalize_proposal_and_create_contract(p_proposal_id)
--
-- CONCEPT SUMMARY (for exam explanation):
--   1. OUTER BLOCK handles the top-level transaction.
--   2. INNER NESTED BLOCK wraps the INSERT so we can catch
--      only insert-specific errors and still rollback cleanly.
--   3. IF / ELSIF / ELSE guards business rules before any DML.
--   4. EXCEPTION sections rollback by re-raising the error.
-- ============================================================

CREATE OR REPLACE PROCEDURE finalize_proposal_and_create_contract(p_proposal_id BIGINT)
    LANGUAGE plpgsql
AS $$
DECLARE
    -- Variables we'll populate from SELECTs
    v_proposal_status  VARCHAR(50);
    v_job_id           BIGINT;
    v_job_status_id    INTEGER;
    v_job_status_name  VARCHAR(50);
    v_freelancer_id    BIGINT;
    v_bid_amount       DECIMAL(15,2);
    v_new_contract_id  BIGINT;
BEGIN
    -- ══ OUTER BLOCK ══════════════════════════════════════════
    -- Fetch proposal data
    SELECT status, job_id, freelancer_id, bid_amount
    INTO   v_proposal_status, v_job_id, v_freelancer_id, v_bid_amount
    FROM   proposals
    WHERE  id = p_proposal_id;

    -- ① IF: check the proposal actually exists
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Proposal % does not exist.', p_proposal_id;
    END IF;

    -- ② IF/ELSE: proposal must be 'pending'
    IF v_proposal_status <> 'pending' THEN
        RAISE EXCEPTION
            'Proposal % cannot be accepted – current status is "%".',
            p_proposal_id, v_proposal_status;
    END IF;

    -- Fetch job status
    SELECT j.status_id, js.status_name
    INTO   v_job_status_id, v_job_status_name
    FROM   jobs j
               JOIN   job_statuses js ON js.id = j.status_id
    WHERE  j.id = v_job_id;

    -- ③ IF/ELSE: job must be 'OPEN'
    IF v_job_status_name <> 'OPEN' THEN
        RAISE EXCEPTION
            'Job % cannot be contracted – current status is "%".',
            v_job_id, v_job_status_name;
    END IF;

    -- ──────────────────────────────────────────────────────────
    -- All guards passed – begin DML inside a NESTED BLOCK so
    -- we can catch insert errors independently.
    -- ──────────────────────────────────────────────────────────
    BEGIN
        -- ══ NESTED INNER BLOCK ════════════════════════════════

        -- Step 1: mark proposal accepted
        UPDATE proposals
        SET    status = 'accepted'
        WHERE  id = p_proposal_id;

        -- Step 2: mark job as IN_PROGRESS  (status_id = 2)
        UPDATE jobs
        SET    status_id = 2
        WHERE  id = v_job_id;

        -- Step 3: create contract
        INSERT INTO contracts (job_id, freelancer_id, total_amount, status)
        VALUES (v_job_id, v_freelancer_id, v_bid_amount, 'active')
        RETURNING id INTO v_new_contract_id;

        RAISE NOTICE 'Contract % created for job % with freelancer %.',
            v_new_contract_id, v_job_id, v_freelancer_id;

    EXCEPTION
        -- ④ EXCEPTION HANDLING in nested block:
        --    catches any error during the DML steps.
        WHEN OTHERS THEN
            RAISE EXCEPTION
                'Contract creation failed (proposal %). Rolling back. Detail: %',
                p_proposal_id, SQLERRM;
        -- PostgreSQL automatically rolls back the transaction when
        -- RAISE EXCEPTION propagates out of a procedure called
        -- without an explicit SAVEPOINT.
    END;
    -- ══ END NESTED BLOCK ═════════════════════════════════════

EXCEPTION
    -- Outer exception block catches guard-clause errors and re-raises
    WHEN OTHERS THEN
        RAISE;
END;
$$;