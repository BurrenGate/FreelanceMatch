CREATE OR REPLACE FUNCTION admin_management.get_transactions(
    p_contract_id BIGINT,
    p_type VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    amount DECIMAL,
    type VARCHAR,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    RETURN QUERY
    SELECT t.id, t.contract_id, t.amount, t.type, t.created_at
    FROM transactions t
    WHERE (p_contract_id IS NULL OR t.contract_id = p_contract_id)
      AND (p_type IS NULL OR UPPER(t.type) = UPPER(p_type))
    ORDER BY t.created_at DESC, t.id DESC;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.get_transaction_by_id(
    p_transaction_id BIGINT,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    amount DECIMAL,
    type VARCHAR,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF NOT EXISTS (SELECT 1 FROM transactions WHERE transactions.id = p_transaction_id) THEN
        RAISE EXCEPTION 'Transaction % not found', p_transaction_id;
    END IF;

    RETURN QUERY
    SELECT t.id, t.contract_id, t.amount, t.type, t.created_at
    FROM transactions t
    WHERE t.id = p_transaction_id;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.create_transaction(
    p_contract_id BIGINT,
    p_amount DECIMAL,
    p_type VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    amount DECIMAL,
    type VARCHAR,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_type VARCHAR;
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    v_type := LOWER(BTRIM(p_type));

    IF p_contract_id IS NULL THEN
        RAISE EXCEPTION 'Contract id is required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM contracts WHERE contracts.id = p_contract_id) THEN
        RAISE EXCEPTION 'Contract % not found', p_contract_id;
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE EXCEPTION 'Amount must be greater than zero';
    END IF;

    IF v_type IS NULL OR v_type = '' THEN
        RAISE EXCEPTION 'Transaction type cannot be empty';
    END IF;

    IF v_type NOT IN ('payment', 'refund', 'commission', 'bonus') THEN
        RAISE EXCEPTION 'Unsupported transaction type %. Allowed: payment, refund, commission, bonus', v_type;
    END IF;

    RETURN QUERY
    INSERT INTO transactions(contract_id, amount, type)
    VALUES (p_contract_id, p_amount, v_type)
    RETURNING transactions.id, transactions.contract_id, transactions.amount, transactions.type, transactions.created_at;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.update_transaction(
    p_transaction_id BIGINT,
    p_contract_id BIGINT,
    p_amount DECIMAL,
    p_type VARCHAR,
    p_admin_email VARCHAR
)
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    amount DECIMAL,
    type VARCHAR,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_type VARCHAR;
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);
    v_type := LOWER(BTRIM(p_type));

    IF NOT EXISTS (SELECT 1 FROM transactions WHERE transactions.id = p_transaction_id) THEN
        RAISE EXCEPTION 'Transaction % not found', p_transaction_id;
    END IF;

    IF p_contract_id IS NULL THEN
        RAISE EXCEPTION 'Contract id is required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM contracts WHERE contracts.id = p_contract_id) THEN
        RAISE EXCEPTION 'Contract % not found', p_contract_id;
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE EXCEPTION 'Amount must be greater than zero';
    END IF;

    IF v_type IS NULL OR v_type = '' THEN
        RAISE EXCEPTION 'Transaction type cannot be empty';
    END IF;

    IF v_type NOT IN ('payment', 'refund', 'commission', 'bonus') THEN
        RAISE EXCEPTION 'Unsupported transaction type %. Allowed: payment, refund, commission, bonus', v_type;
    END IF;

    RETURN QUERY
    UPDATE transactions
    SET contract_id = p_contract_id,
        amount = p_amount,
        type = v_type
    WHERE transactions.id = p_transaction_id
    RETURNING transactions.id, transactions.contract_id, transactions.amount, transactions.type, transactions.created_at;
END;
$$;

CREATE OR REPLACE PROCEDURE admin_management.delete_transaction(
    p_transaction_id BIGINT,
    p_admin_email VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF NOT EXISTS (SELECT 1 FROM transactions WHERE transactions.id = p_transaction_id) THEN
        RAISE EXCEPTION 'Transaction % not found', p_transaction_id;
    END IF;

    DELETE FROM transactions
    WHERE transactions.id = p_transaction_id;
END;
$$;
