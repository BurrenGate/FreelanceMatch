-- V34: Milestone-based payments for contracts

-- Create schema if not exists
CREATE SCHEMA IF NOT EXISTS payment_management;

-- Table for contract milestones
CREATE TABLE contract_milestones (
    id              BIGSERIAL PRIMARY KEY,
    contract_id     BIGINT REFERENCES contracts(id) ON DELETE CASCADE NOT NULL,
    title           VARCHAR(255) NOT NULL,
    description     TEXT,
    amount          DECIMAL(15,2) NOT NULL CHECK (amount > 0),
    status          VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'completed', 'paid')),
    due_date        DATE,
    completed_at    TIMESTAMP,
    paid_at         TIMESTAMP,
    created_at      TIMESTAMP DEFAULT NOW(),
    updated_at      TIMESTAMP DEFAULT NOW()
);

-- Add milestone tracking to contracts
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS paid_amount DECIMAL(15,2) DEFAULT 0 CHECK (paid_amount >= 0);
ALTER TABLE contracts ADD COLUMN IF NOT EXISTS remaining_amount DECIMAL(15,2);

-- Update remaining_amount for existing contracts
UPDATE contracts SET remaining_amount = total_amount - COALESCE(paid_amount, 0) WHERE remaining_amount IS NULL;

-- Indexes
CREATE INDEX idx_milestones_contract ON contract_milestones(contract_id);
CREATE INDEX idx_milestones_status ON contract_milestones(status);

-- Function to create milestone
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
    v_paid_amount DECIMAL(15,2);
    v_milestones_total DECIMAL(15,2);
BEGIN
    -- Check contract exists and is active
    SELECT status, total_amount, paid_amount
    INTO v_contract_status, v_total_amount, v_paid_amount
    FROM contracts
    WHERE id = p_contract_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract % not found', p_contract_id;
    END IF;
    
    IF v_contract_status != 'active' THEN
        RAISE EXCEPTION 'Can only create milestones for active contracts';
    END IF;
    
    -- Check if total milestones amount doesn't exceed contract amount
    SELECT COALESCE(SUM(amount), 0) INTO v_milestones_total
    FROM contract_milestones
    WHERE contract_id = p_contract_id;
    
    IF (v_milestones_total + p_amount) > v_total_amount THEN
        RAISE EXCEPTION 'Total milestones amount (% + %) exceeds contract amount (%)', 
            v_milestones_total, p_amount, v_total_amount;
    END IF;
    
    -- Create milestone
    INSERT INTO contract_milestones (contract_id, title, description, amount, due_date)
    VALUES (p_contract_id, p_title, p_description, p_amount, p_due_date)
    RETURNING id INTO v_milestone_id;
    
    RAISE NOTICE 'Milestone % created for contract %', v_milestone_id, p_contract_id;
    
    RETURN v_milestone_id;
END;
$$;

-- Function to update milestone status
CREATE OR REPLACE FUNCTION payment_management.update_milestone_status(
    p_milestone_id BIGINT,
    p_status VARCHAR(50)
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(50);
BEGIN
    -- Get current status
    SELECT status INTO v_current_status
    FROM contract_milestones
    WHERE id = p_milestone_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Milestone % not found', p_milestone_id;
    END IF;
    
    -- Validate status transition
    IF p_status NOT IN ('pending', 'in_progress', 'completed', 'paid') THEN
        RAISE EXCEPTION 'Invalid status: %', p_status;
    END IF;
    
    -- Update status
    UPDATE contract_milestones
    SET status = p_status,
        completed_at = CASE WHEN p_status = 'completed' THEN NOW() ELSE completed_at END,
        updated_at = NOW()
    WHERE id = p_milestone_id;
    
    RAISE NOTICE 'Milestone % status updated to %', p_milestone_id, p_status;
    
    RETURN p_status;
END;
$$;

-- Function to pay milestone
CREATE OR REPLACE FUNCTION payment_management.pay_milestone(
    p_milestone_id BIGINT,
    p_payer_id BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_contract_id BIGINT;
    v_milestone_amount DECIMAL(15,2);
    v_milestone_status VARCHAR(50);
    v_transaction_id BIGINT;
    v_freelancer_id BIGINT;
    v_client_id BIGINT;
BEGIN
    -- Get milestone details
    SELECT contract_id, amount, status
    INTO v_contract_id, v_milestone_amount, v_milestone_status
    FROM contract_milestones
    WHERE id = p_milestone_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Milestone % not found', p_milestone_id;
    END IF;
    
    -- Check milestone is completed
    IF v_milestone_status != 'completed' THEN
        RAISE EXCEPTION 'Milestone must be completed before payment. Current status: %', v_milestone_status;
    END IF;
    
    -- Get contract participants
    SELECT c.freelancer_id, j.client_id
    INTO v_freelancer_id, v_client_id
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = v_contract_id;
    
    -- Verify payer is client
    IF p_payer_id != v_client_id THEN
        RAISE EXCEPTION 'Only client can pay milestones';
    END IF;
    
    -- Create transaction
    INSERT INTO transactions (contract_id, amount, type, created_at)
    VALUES (v_contract_id, v_milestone_amount, 'milestone_payment', NOW())
    RETURNING id INTO v_transaction_id;
    
    -- Update milestone status to paid
    UPDATE contract_milestones
    SET status = 'paid',
        paid_at = NOW(),
        updated_at = NOW()
    WHERE id = p_milestone_id;
    
    -- Update contract paid amount
    UPDATE contracts
    SET paid_amount = COALESCE(paid_amount, 0) + v_milestone_amount,
        remaining_amount = total_amount - (COALESCE(paid_amount, 0) + v_milestone_amount)
    WHERE id = v_contract_id;
    
    RAISE NOTICE 'Milestone % paid. Transaction % created', p_milestone_id, v_transaction_id;
    
    RETURN v_transaction_id;
END;
$$;

-- Function to get contract milestones
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
    -- Verify user is participant
    SELECT c.freelancer_id, j.client_id
    INTO v_freelancer_id, v_client_id
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract % not found', p_contract_id;
    END IF;
    
    IF p_user_id != v_freelancer_id AND p_user_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not a participant of contract %', p_user_id, p_contract_id;
    END IF;
    
    -- Return milestones
    RETURN QUERY
    SELECT 
        m.id AS milestone_id,
        m.title,
        m.description,
        m.amount,
        m.status,
        m.due_date,
        m.completed_at,
        m.paid_at,
        m.created_at
    FROM contract_milestones m
    WHERE m.contract_id = p_contract_id
    ORDER BY m.created_at ASC;
END;
$$;

-- Function to get contract payment summary
CREATE OR REPLACE FUNCTION payment_management.get_contract_payment_summary(
    p_contract_id BIGINT,
    p_user_id BIGINT
)
RETURNS TABLE (
    contract_id BIGINT,
    total_amount DECIMAL(15,2),
    paid_amount DECIMAL(15,2),
    remaining_amount DECIMAL(15,2),
    total_milestones INTEGER,
    pending_milestones INTEGER,
    completed_milestones INTEGER,
    paid_milestones INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_freelancer_id BIGINT;
    v_client_id BIGINT;
BEGIN
    -- Verify user is participant
    SELECT c.freelancer_id, j.client_id
    INTO v_freelancer_id, v_client_id
    FROM contracts c
    JOIN jobs j ON j.id = c.job_id
    WHERE c.id = p_contract_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Contract % not found', p_contract_id;
    END IF;
    
    IF p_user_id != v_freelancer_id AND p_user_id != v_client_id THEN
        RAISE EXCEPTION 'User % is not a participant of contract %', p_user_id, p_contract_id;
    END IF;
    
    -- Return payment summary
    RETURN QUERY
    SELECT 
        c.id AS contract_id,
        c.total_amount,
        COALESCE(c.paid_amount, 0) AS paid_amount,
        c.total_amount - COALESCE(c.paid_amount, 0) AS remaining_amount,
        COUNT(m.id)::INTEGER AS total_milestones,
        COUNT(CASE WHEN m.status = 'pending' THEN 1 END)::INTEGER AS pending_milestones,
        COUNT(CASE WHEN m.status = 'completed' THEN 1 END)::INTEGER AS completed_milestones,
        COUNT(CASE WHEN m.status = 'paid' THEN 1 END)::INTEGER AS paid_milestones
    FROM contracts c
    LEFT JOIN contract_milestones m ON m.contract_id = c.id
    WHERE c.id = p_contract_id
    GROUP BY c.id, c.total_amount, c.paid_amount;
END;
$$;

COMMENT ON TABLE contract_milestones IS 'Milestones for partial payments in contracts';
COMMENT ON FUNCTION payment_management.create_milestone IS 'Create a new milestone for a contract';
COMMENT ON FUNCTION payment_management.update_milestone_status IS 'Update milestone status';
COMMENT ON FUNCTION payment_management.pay_milestone IS 'Pay a completed milestone';
COMMENT ON FUNCTION payment_management.get_contract_milestones IS 'Get all milestones for a contract';
COMMENT ON FUNCTION payment_management.get_contract_payment_summary IS 'Get payment summary for a contract';
