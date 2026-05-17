-- V46: Recreate all chat functions with correct signatures

-- Ensure schema exists
CREATE SCHEMA IF NOT EXISTS chat_management;

-- Drop all existing chat functions
DROP FUNCTION IF EXISTS chat_management.get_user_conversations(BIGINT) CASCADE;
DROP FUNCTION IF EXISTS chat_management.get_available_chat_partners(BIGINT) CASCADE;
DROP FUNCTION IF EXISTS chat_management.get_conversation_messages(BIGINT, BIGINT, INTEGER, INTEGER) CASCADE;

-- Recreate get_user_conversations
CREATE OR REPLACE FUNCTION chat_management.get_user_conversations(
    p_user_id BIGINT
)
RETURNS TABLE (
    conversation_id BIGINT,
    contract_id BIGINT,
    other_user_id BIGINT,
    other_user_name TEXT,
    other_user_avatar VARCHAR(1000),
    last_message_text TEXT,
    last_message_at TIMESTAMP,
    unread_count BIGINT,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id AS conversation_id,
        c.contract_id,
        CASE 
            WHEN c.client_id = p_user_id THEN c.freelancer_id
            ELSE c.client_id
        END AS other_user_id,
        CASE 
            WHEN c.client_id = p_user_id THEN CONCAT(fp.first_name, ' ', fp.last_name)
            ELSE CONCAT(cp.first_name, ' ', cp.last_name)
        END AS other_user_name,
        CASE 
            WHEN c.client_id = p_user_id THEN fp.avatar_url
            ELSE cp.avatar_url
        END AS other_user_avatar,
        (SELECT message_text FROM chat_messages 
         WHERE conversation_id = c.id 
         ORDER BY created_at DESC LIMIT 1) AS last_message_text,
        c.last_message_at,
        (SELECT COUNT(*) FROM chat_messages 
         WHERE conversation_id = c.id 
           AND sender_id != p_user_id 
           AND is_read = FALSE) AS unread_count,
        c.created_at
    FROM chat_conversations c
    JOIN profiles cp ON cp.id = c.client_id
    JOIN profiles fp ON fp.id = c.freelancer_id
    WHERE c.client_id = p_user_id OR c.freelancer_id = p_user_id
    ORDER BY c.last_message_at DESC;
END;
$$;

-- Recreate get_available_chat_partners (all people with job/proposal history)
CREATE OR REPLACE FUNCTION chat_management.get_available_chat_partners(
    p_user_id BIGINT
)
RETURNS TABLE (
    partner_id BIGINT,
    partner_name TEXT,
    partner_avatar VARCHAR(1000),
    partner_role VARCHAR(50),
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
    
    -- If user is client (role_id = 1), return all freelancers with any job/proposal history
    IF v_user_role_id = 1 THEN
        RETURN QUERY
        SELECT DISTINCT
            p.freelancer_id AS partner_id,
            CONCAT(fp.first_name, ' ', fp.last_name) AS partner_name,
            fp.avatar_url AS partner_avatar,
            'freelancer'::VARCHAR(50) AS partner_role,
            cc.id AS conversation_id,
            (cc.id IS NOT NULL) AS has_conversation
        FROM proposals p
        JOIN jobs j ON j.id = p.job_id
        JOIN profiles fp ON fp.id = p.freelancer_id
        LEFT JOIN chat_conversations cc ON (cc.client_id = j.client_id AND cc.freelancer_id = p.freelancer_id)
        WHERE j.client_id = p_user_id
        ORDER BY partner_id;
    
    -- If user is freelancer (role_id = 2), return all clients with any job/proposal history
    ELSIF v_user_role_id = 2 THEN
        RETURN QUERY
        SELECT DISTINCT
            j.client_id AS partner_id,
            CONCAT(cp.first_name, ' ', cp.last_name) AS partner_name,
            cp.avatar_url AS partner_avatar,
            'client'::VARCHAR(50) AS partner_role,
            cc.id AS conversation_id,
            (cc.id IS NOT NULL) AS has_conversation
        FROM proposals p
        JOIN jobs j ON j.id = p.job_id
        JOIN profiles cp ON cp.id = j.client_id
        LEFT JOIN chat_conversations cc ON (cc.client_id = j.client_id AND cc.freelancer_id = p.freelancer_id)
        WHERE p.freelancer_id = p_user_id
        ORDER BY partner_id;
    END IF;
END;
$$;

-- Recreate get_conversation_messages
CREATE OR REPLACE FUNCTION chat_management.get_conversation_messages(
    p_conversation_id BIGINT,
    p_user_id BIGINT,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    message_id BIGINT,
    sender_id BIGINT,
    sender_name TEXT,
    message_text TEXT,
    file_object_name VARCHAR(500),
    file_url VARCHAR(1000),
    file_type VARCHAR(50),
    file_size BIGINT,
    is_read BOOLEAN,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_client_id BIGINT;
    v_freelancer_id BIGINT;
BEGIN
    -- Verify user is participant
    SELECT client_id, freelancer_id INTO v_client_id, v_freelancer_id
    FROM chat_conversations
    WHERE id = p_conversation_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Conversation % not found', p_conversation_id;
    END IF;
    
    IF p_user_id != v_client_id AND p_user_id != v_freelancer_id THEN
        RAISE EXCEPTION 'User % is not a participant of conversation %', p_user_id, p_conversation_id;
    END IF;
    
    -- Return messages
    RETURN QUERY
    SELECT 
        m.id AS message_id,
        m.sender_id,
        CONCAT(p.first_name, ' ', p.last_name) AS sender_name,
        m.message_text,
        m.file_object_name,
        m.file_url,
        m.file_type,
        m.file_size,
        m.is_read,
        m.created_at
    FROM chat_messages m
    JOIN profiles p ON p.id = m.sender_id
    WHERE m.conversation_id = p_conversation_id
    ORDER BY m.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;

COMMENT ON FUNCTION chat_management.get_user_conversations IS 'Get all conversations for a user';
COMMENT ON FUNCTION chat_management.get_available_chat_partners IS 'Get all people user has job/proposal history with';
COMMENT ON FUNCTION chat_management.get_conversation_messages IS 'Get messages from conversation';
