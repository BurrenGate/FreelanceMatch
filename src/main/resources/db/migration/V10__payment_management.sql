-- V10: This script implements a milestone-based payment system, allowing contracts
-- to be broken down into smaller, manageable, and payable stages.

CREATE SCHEMA IF NOT EXISTS payment_management;

-- =============================================================================
-- Milestone Management Functions
-- =============================================================================

-- Function to create a new milestone for an active contract.
CREATE OR REPLACE FUNCTION payment_management.create_milestone(
    p_contract_id BIGINT,
    p_title VARCHAR(255),
    p_description TEXT,
    p_amount DECIMAL(15,2),
    p_due_date DATE DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_milestone_id BIGINT;
    v_contract_status VARCHAR(50);
    v_total_amount DECIMAL(15,2);
    v_milestones_total DECIMAL(15,2);
BEGIN
    -- Validate that the contract exists and is active.
    SELECT status, total_amount
    INTO v_contract_status, v_total_amount
    FROM contracts
    WHERE id = p_contract_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract with ID % not found.', p_contract_id;
    END IF;

    IF v_contract_status != 'active' THEN
        RAISE EXCEPTION 'Milestones can only be created for active contracts.';
    END IF;

    -- Ensure the sum of all milestones does not exceed the total contract amount.
    SELECT COALESCE(SUM(amount), 0) INTO v_milestones_total
    FROM contract_milestones
    WHERE contract_id = p_contract_id;

    IF (v_milestones_total + p_amount) > v_total_amount THEN
        RAISE EXCEPTION 'The total amount of milestones cannot exceed the contract''s total amount (%).', v_total_amount;
    END IF;

    -- Create the new milestone.
    INSERT INTO contract_milestones (contract_id, title, description, amount, due_date)
    VALUES (p_contract_id, p_title, p_description, p_amount, p_due_date)
    RETURNING id INTO v_milestone_id;

    RAISE NOTICE 'Milestone % created for contract %.', v_milestone_id, p_contract_id;

    RETURN v_milestone_id;
END;
$$;
COMMENT ON FUNCTION payment_management.create_milestone(BIGINT, VARCHAR, TEXT, DECIMAL, DATE)
IS 'Creates a new payment milestone for a contract.';

-- Function to update the status of a milestone.
CREATE OR REPLACE FUNCTION payment_management.update_milestone_status(
    p_milestone_id BIGINT,
    p_status VARCHAR(50)
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validate the new status.
    IF p_status NOT IN ('pending', 'in_progress', 'completed', 'paid') THEN
        RAISE EXCEPTION 'Invalid milestone status: %.', p_status;
    END IF;

    -- Update the milestone status and relevant timestamps.
    UPDATE contract_milestones
    SET status = p_status,
        completed_at = CASE WHEN p_status = 'completed' AND status != 'completed' THEN NOW() ELSE completed_at END,
        updated_at = NOW()
    WHERE id = p_milestone_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Milestone with ID % not found.', p_milestone_id;
    END IF;

    RAISE NOTICE 'Milestone % status updated to %.', p_milestone_id, p_status;

    RETURN p_status;
END;
$$;
COMMENT ON FUNCTION payment_management.update_milestone_status(BIGINT, VARCHAR)
IS 'Updates the status of a contract milestone (e.g., to completed).';

-- Function to process the payment for a completed milestone.
CREATE OR REPLACE FUNCTION payment_management.pay_milestone(
    p_milestone_id BIGINT,
    p_payer_id BIGINT -- This should be the profile ID of the client.
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_contract_id BIGINT;
    v_milestone_amount DECIMAL(15,2);
    v_milestone_status VARCHAR(50);
    v_transaction_id BIGINT;
    v_client_id BIGINT;
BEGIN
    -- Retrieve milestone details.
    SELECT contract_id, amount, status
    INTO v_contract_id, v_milestone_amount, v_milestone_status
    FROM contract_milestones
    WHERE id = p_milestone_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Milestone with ID % not found.', p_milestone_id;
    END IF;

    -- A milestone must be 'completed' before it can be paid.
    IF v_milestone_status != 'completed' THEN
        RAISE EXCEPTION 'Milestone must be marked as completed before payment. Current status: %', v_milestone_status;
    END IF;

    -- Verify that the payer is the client on the contract.
    SELECT j.client_id INTO v_client_id
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = v_contract_id;

    IF p_payer_id != v_client_id THEN
        RAISE EXCEPTION 'Only the client can make payments for this contract.';
    END IF;

    -- Create a transaction record for the payment.
    INSERT INTO transactions (contract_id, amount, type)
    VALUES (v_contract_id, v_milestone_amount, 'milestone_payment')
    RETURNING id INTO v_transaction_id;

    -- Update the milestone to 'paid'.
    UPDATE contract_milestones
    SET status = 'paid',
        paid_at = NOW(),
        updated_at = NOW()
    WHERE id = p_milestone_id;

    -- Update the contract's paid amount.
    UPDATE contracts
    SET paid_amount = COALESCE(paid_amount, 0) + v_milestone_amount
    WHERE id = v_contract_id;

    RAISE NOTICE 'Milestone % paid. Transaction % created.', p_milestone_id, v_transaction_id;

    RETURN v_transaction_id;
END;
$$;
COMMENT ON FUNCTION payment_management.pay_milestone(BIGINT, BIGINT)
IS 'Processes the payment for a completed milestone and updates contract totals.';

-- =============================================================================
-- Data Retrieval Functions
-- =============================================================================

-- Function to get all milestones for a contract.
-- Access is restricted to the contract's participants.
CREATE OR REPLACE FUNCTION payment_management.get_contract_milestones(
    p_contract_id BIGINT,
    p_user_id BIGINT
)
RETURNS TABLE (
    milestone_id BIGINT,
    title VARCHAR(255),
    description TEXT,
    amount DECIMAL(15,2),
    status VARCHAR(50),
    due_date DATE,
    completed_at TIMESTAMP,
    paid_at TIMESTAMP,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_freelancer_id BIGINT;
    v_client_id BIGINT;
BEGIN
    -- Verify that the user is a participant in the contract.
    SELECT c.freelancer_id, j.client_id
    INTO v_freelancer_id, v_client_id
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract with ID % not found.', p_contract_id;
    END IF;

    IF p_user_id != v_freelancer_id AND p_user_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not authorized to view milestones for contract %.', p_user_id, p_contract_id;
    END IF;

    -- Return all milestones for the contract.
    RETURN QUERY
    SELECT
        m.id, m.title, m.description, m.amount, m.status,
        m.due_date, m.completed_at, m.paid_at, m.created_at
    FROM contract_milestones m
    WHERE m.contract_id = p_contract_id
    ORDER BY m.created_at ASC;
END;
$$;
COMMENT ON FUNCTION payment_management.get_contract_milestones(BIGINT, BIGINT)
IS 'Retrieves all milestones for a given contract, accessible only by its participants.';

-- Function to get a payment summary for a contract.
-- This includes total, paid, and remaining amounts, along with milestone counts.
CREATE OR REPLACE FUNCTION payment_management.get_contract_payment_summary(
    p_contract_id BIGINT,
    p_user_id BIGINT
)
RETURNS TABLE (
    contract_id BIGINT,
    total_amount DECIMAL(15,2),
    paid_amount DECIMAL(15,2),
    remaining_amount DECIMAL(15,2),
    total_milestones BIGINT,
    pending_milestones BIGINT,
    completed_milestones BIGINT,
    paid_milestones BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_freelancer_id BIGINT;
    v_client_id BIGINT;
BEGIN
    -- Verify that the user is a participant in the contract.
    SELECT c.freelancer_id, j.client_id
    INTO v_freelancer_id, v_client_id
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract with ID % not found.', p_contract_id;
    END IF;

    IF p_user_id != v_freelancer_id AND p_user_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not authorized to view the payment summary for contract %.', p_user_id, p_contract_id;
    END IF;

    -- Return the payment summary.
    RETURN QUERY
    SELECT
        c.id,
        c.total_amount,
        COALESCE(c.paid_amount, 0),
        c.total_amount - COALESCE(c.paid_amount, 0),
        COUNT(m.id),
        COUNT(m.id) FILTER (WHERE m.status = 'pending'),
        COUNT(m.id) FILTER (WHERE m.status = 'completed'),
        COUNT(m.id) FILTER (WHERE m.status = 'paid')
    FROM contracts c
    LEFT JOIN contract_milestones m ON m.contract_id = c.id
    WHERE c.id = p_contract_id
    GROUP BY c.id;
END;
$$;
COMMENT ON FUNCTION payment_management.get_contract_payment_summary(BIGINT, BIGINT)
IS 'Provides a financial summary of a contract, including milestone status counts.';
