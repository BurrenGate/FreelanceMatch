-- V42: Auto-create chat conversation when contract is created

-- Function to auto-create conversation on contract creation
CREATE OR REPLACE FUNCTION chat_management.auto_create_conversation_on_contract()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_client_id BIGINT;
    v_conversation_id BIGINT;
BEGIN
    -- Get client_id from job
    SELECT client_id INTO v_client_id
    FROM jobs
    WHERE id = NEW.job_id;
    
    -- Check if conversation already exists for this contract
    SELECT id INTO v_conversation_id
    FROM chat_conversations
    WHERE contract_id = NEW.id;
    
    -- If conversation doesn't exist, create it
    IF v_conversation_id IS NULL THEN
        INSERT INTO chat_conversations (contract_id, client_id, freelancer_id)
        VALUES (NEW.id, v_client_id, NEW.freelancer_id)
        RETURNING id INTO v_conversation_id;
        
        RAISE NOTICE 'Auto-created conversation % for contract %', v_conversation_id, NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$;

-- Create trigger to auto-create conversation when contract is created
DROP TRIGGER IF EXISTS trigger_auto_create_conversation ON contracts;
CREATE TRIGGER trigger_auto_create_conversation
    AFTER INSERT ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION chat_management.auto_create_conversation_on_contract();

-- Function to get available chat partners (people you can chat with)
CREATE OR REPLACE FUNCTION chat_management.get_available_chat_partners(
    p_user_id BIGINT
)
RETURNS TABLE (
    partner_id BIGINT,
    partner_name TEXT,
    partner_avatar VARCHAR(1000),
    partner_role VARCHAR(50),
    contract_id BIGINT,
    contract_status VARCHAR(50),
    job_title VARCHAR(255),
    conversation_id BIGINT,
    has_conversation BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_user_role_id INTEGER;
BEGIN
    -- Get user role
    SELECT a.role_id INTO v_user_role_id
    FROM accounts a
    JOIN profiles p ON p.account_id = a.id
    WHERE p.id = p_user_id;
    
    -- If user is client (role_id = 1), return freelancers they have contracts with
    IF v_user_role_id = 1 THEN
        RETURN QUERY
        SELECT DISTINCT
            c.freelancer_id AS partner_id,
            CONCAT(fp.first_name, ' ', fp.last_name) AS partner_name,
            fp.avatar_url AS partner_avatar,
            'freelancer' AS partner_role,
            c.id AS contract_id,
            c.status AS contract_status,
            j.title AS job_title,
            cc.id AS conversation_id,
            (cc.id IS NOT NULL) AS has_conversation
        FROM contracts c
        JOIN jobs j ON j.id = c.job_id
        JOIN profiles fp ON fp.id = c.freelancer_id
        LEFT JOIN chat_conversations cc ON cc.contract_id = c.id
        WHERE j.client_id = p_user_id
        ORDER BY c.created_at DESC;
    
    -- If user is freelancer (role_id = 2), return clients they have contracts with
    ELSIF v_user_role_id = 2 THEN
        RETURN QUERY
        SELECT DISTINCT
            j.client_id AS partner_id,
            CONCAT(cp.first_name, ' ', cp.last_name) AS partner_name,
            cp.avatar_url AS partner_avatar,
            'client' AS partner_role,
            c.id AS contract_id,
            c.status AS contract_status,
            j.title AS job_title,
            cc.id AS conversation_id,
            (cc.id IS NOT NULL) AS has_conversation
        FROM contracts c
        JOIN jobs j ON j.id = c.job_id
        JOIN profiles cp ON cp.id = j.client_id
        LEFT JOIN chat_conversations cc ON cc.contract_id = c.id
        WHERE c.freelancer_id = p_user_id
        ORDER BY c.created_at DESC;
    END IF;
END;
$$;

COMMENT ON FUNCTION chat_management.auto_create_conversation_on_contract IS 'Automatically create chat conversation when contract is created';
COMMENT ON FUNCTION chat_management.get_available_chat_partners IS 'Get list of people user can chat with based on contracts';
