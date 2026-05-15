-- =============================================================================
-- V14__add_triggers.sql
-- Business-logic triggers for the freelance platform
-- =============================================================================

-- -----------------------------------------------------------------------------
-- TRIGGER 1: Auto-stamp profiles.updated_at on every UPDATE
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_profile_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_profile_updated_at ON profiles;
CREATE TRIGGER trg_profile_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_profile_updated_at();


-- -----------------------------------------------------------------------------
-- TRIGGER 3: When a contract is created, move the job to IN_PROGRESS (status 2)
--            and reject all other pending proposals for that job.
--            Keeps finalize_proposal_and_create_contract() leaner.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_contract_created()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    -- Move job to IN_PROGRESS
    UPDATE jobs
    SET    status_id = 2          -- IN_PROGRESS
    WHERE  id = NEW.job_id
      AND  status_id = 1;         -- only if still OPEN (safety guard)

    IF NOT FOUND THEN
        RAISE EXCEPTION
            'Cannot create contract: job % is not OPEN.', NEW.job_id;
    END IF;

    UPDATE proposals
        SET status = 'accepted'
    WHERE  job_id = NEW.job_id
      AND  freelancer_id = NEW.freelancer_id;

    UPDATE proposals
    SET    status = 'rejected'
    WHERE  job_id        = NEW.job_id
      AND  freelancer_id <> NEW.freelancer_id
      AND  status        = 'pending';

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_contract_created ON contracts;
CREATE TRIGGER trg_contract_created
    AFTER INSERT ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_contract_created();


-- -----------------------------------------------------------------------------
-- TRIGGER 4: When a contract moves to 'completed', close the job (status 3)
--            and insert a payment transaction automatically.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_contract_completed()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    -- Only act on the active → completed transition
    IF OLD.status = 'active' AND NEW.status = 'completed' THEN

        UPDATE jobs
        SET    status_id = 3      -- COMPLETED
        WHERE  id = NEW.job_id;

        INSERT INTO transactions (contract_id, amount, type)
        VALUES (NEW.id, NEW.total_amount, 'payment');

    END IF;
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_contract_completed ON contracts;
CREATE TRIGGER trg_contract_completed
    AFTER UPDATE OF status ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_contract_completed();


-- -----------------------------------------------------------------------------
-- TRIGGER 5: Prevent a freelancer from reviewing their own contract.
--            Second line of defence after the app layer.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_prevent_self_review()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
    v_freelancer_id BIGINT;
BEGIN
    SELECT freelancer_id
    INTO   v_freelancer_id
    FROM   contracts
    WHERE  id = NEW.contract_id;

    IF NEW.reviewer_id = v_freelancer_id THEN
        RAISE EXCEPTION
            'Freelancer (profile %) cannot review their own contract (%).',
            NEW.reviewer_id, NEW.contract_id;
    END IF;

    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_self_review ON reviews;
CREATE TRIGGER trg_prevent_self_review
    BEFORE INSERT ON reviews
    FOR EACH ROW
    EXECUTE FUNCTION trg_fn_prevent_self_review();