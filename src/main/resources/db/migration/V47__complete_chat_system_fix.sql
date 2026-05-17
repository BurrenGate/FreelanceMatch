-- V47: Diagnostic and fix for chat system

-- Ensure schema exists
CREATE SCHEMA IF NOT EXISTS chat_management;

-- Check and recreate tables if needed
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'chat_conversations') THEN
        RAISE NOTICE 'chat_conversations table does not exist, creating...';
        
        CREATE TABLE chat_conversations (
            id              BIGSERIAL PRIMARY KEY,
            contract_id     BIGINT REFERENCES contracts(id) ON DELETE CASCADE,
            client_id       BIGINT REFERENCES profiles(id) NOT NULL,
            freelancer_id   BIGINT REFERENCES profiles(id) NOT NULL,
            last_message_at TIMESTAMP DEFAULT NOW(),
            created_at      TIMESTAMP DEFAULT NOW(),
            UNIQUE(contract_id),
            CONSTRAINT check_different_participants CHECK (client_id != freelancer_id)
        );
        
        CREATE INDEX idx_chat_conversations_client ON chat_conversations(client_id);
        CREATE INDEX idx_chat_conversations_freelancer ON chat_conversations(freelancer_id);
        CREATE INDEX idx_chat_conversations_contract ON chat_conversations(contract_id);
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'chat_messages') THEN
        RAISE NOTICE 'chat_messages table does not exist, creating...';
        
        CREATE TABLE chat_messages (
            id                BIGSERIAL PRIMARY KEY,
            conversation_id   BIGINT REFERENCES chat_conversations(id) ON DELETE CASCADE NOT NULL,
            sender_id         BIGINT REFERENCES profiles(id) NOT NULL,
            message_text      TEXT,
            file_object_name  VARCHAR(500),
            file_url          VARCHAR(1000),
            file_type         VARCHAR(50),
            file_size         BIGINT,
            is_read           BOOLEAN DEFAULT FALSE,
            created_at        TIMESTAMP DEFAULT NOW(),
            CONSTRAINT check_message_content CHECK (
                message_text IS NOT NULL OR file_object_name IS NOT NULL
            )
        );
        
        CREATE INDEX idx_chat_messages_conversation ON chat_messages(conversation_id);
        CREATE INDEX idx_chat_messages_sender ON chat_messages(sender_id);
        CREATE INDEX idx_chat_messages_created ON chat_messages(created_at DESC);
        CREATE INDEX idx_chat_messages_unread ON chat_messages(is_read) WHERE is_read = FALSE;
    END IF;
END $$;

-- Drop and recreate all chat functions
DROP FUNCTION IF EXISTS chat_management.get_user_conversations(BIGINT) CASCADE;
DROP FUNCTION IF EXISTS chat_management.get_available_chat_partners(BIGINT) CASCADE;
DROP FUNCTION IF EXISTS chat_management.get_conversation_messages(BIGINT, BIGINT, INTEGER, INTEGER) CASCADE;
DROP FUNCTION IF EXISTS chat_management.get_or_create_conversation(BIGINT, BIGINT, BIGINT) CASCADE;
DROP FUNCTION IF EXISTS chat_management.send_message(BIGINT, BIGINT, TEXT, VARCHAR, VARCHAR, VARCHAR, BIGINT) CASCADE;
DROP FUNCTION IF EXISTS chat_management.mark_messages_as_read(BIGINT, BIGINT) CASCADE;
DROP FUNCTION IF EXISTS chat_management.get_unread_count(BIGINT) CASCADE;

-- get_user_conversations
CREATE OR REPLACE FUNCTION chat_management.get_user_conversations(p_user_id BIGINT)
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
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT 
        c.id, c.contract_id,
        CASE WHEN c.client_id = p_user_id THEN c.freelancer_id ELSE c.client_id END,
        CASE WHEN c.client_id = p_user_id THEN CONCAT(fp.first_name, ' ', fp.last_name) ELSE CONCAT(cp.first_name, ' ', cp.last_name) END,
        CASE WHEN c.client_id = p_user_id THEN fp.avatar_url ELSE cp.avatar_url END,
        (SELECT message_text FROM chat_messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1),
        c.last_message_at,
        (SELECT COUNT(*) FROM chat_messages WHERE conversation_id = c.id AND sender_id != p_user_id AND is_read = FALSE),
        c.created_at
    FROM chat_conversations c
    JOIN profiles cp ON cp.id = c.client_id
    JOIN profiles fp ON fp.id = c.freelancer_id
    WHERE c.client_id = p_user_id OR c.freelancer_id = p_user_id
    ORDER BY c.last_message_at DESC;
END; $$;

-- get_available_chat_partners
CREATE OR REPLACE FUNCTION chat_management.get_available_chat_partners(p_user_id BIGINT)
RETURNS TABLE (
    partner_id BIGINT,
    partner_name TEXT,
    partner_avatar VARCHAR(1000),
    partner_role VARCHAR(50),
    conversation_id BIGINT,
    has_conversation BOOLEAN
)
LANGUAGE plpgsql AS $$
DECLARE
    v_user_role_id INTEGER;
BEGIN
    SELECT a.role_id INTO v_user_role_id FROM accounts a JOIN profiles p ON p.account_id = a.id WHERE p.id = p_user_id;
    
    IF v_user_role_id = 1 THEN
        RETURN QUERY
        SELECT DISTINCT p.freelancer_id, CONCAT(fp.first_name, ' ', fp.last_name), fp.avatar_url, 'freelancer'::VARCHAR(50),
               cc.id, (cc.id IS NOT NULL)
        FROM proposals p
        JOIN jobs j ON j.id = p.job_id
        JOIN profiles fp ON fp.id = p.freelancer_id
        LEFT JOIN chat_conversations cc ON (cc.client_id = j.client_id AND cc.freelancer_id = p.freelancer_id)
        WHERE j.client_id = p_user_id
        ORDER BY p.freelancer_id;
    ELSIF v_user_role_id = 2 THEN
        RETURN QUERY
        SELECT DISTINCT j.client_id, CONCAT(cp.first_name, ' ', cp.last_name), cp.avatar_url, 'client'::VARCHAR(50),
               cc.id, (cc.id IS NOT NULL)
        FROM proposals p
        JOIN jobs j ON j.id = p.job_id
        JOIN profiles cp ON cp.id = j.client_id
        LEFT JOIN chat_conversations cc ON (cc.client_id = j.client_id AND cc.freelancer_id = p.freelancer_id)
        WHERE p.freelancer_id = p_user_id
        ORDER BY j.client_id;
    END IF;
END; $$;

-- get_conversation_messages
CREATE OR REPLACE FUNCTION chat_management.get_conversation_messages(
    p_conversation_id BIGINT, p_user_id BIGINT, p_limit INTEGER DEFAULT 50, p_offset INTEGER DEFAULT 0
)
RETURNS TABLE (
    message_id BIGINT, sender_id BIGINT, sender_name TEXT, message_text TEXT,
    file_object_name VARCHAR(500), file_url VARCHAR(1000), file_type VARCHAR(50),
    file_size BIGINT, is_read BOOLEAN, created_at TIMESTAMP
)
LANGUAGE plpgsql AS $$
DECLARE
    v_client_id BIGINT; v_freelancer_id BIGINT;
BEGIN
    SELECT client_id, freelancer_id INTO v_client_id, v_freelancer_id FROM chat_conversations WHERE id = p_conversation_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Conversation % not found', p_conversation_id; END IF;
    IF p_user_id != v_client_id AND p_user_id != v_freelancer_id THEN RAISE EXCEPTION 'User % is not a participant', p_user_id; END IF;
    
    RETURN QUERY
    SELECT m.id, m.sender_id, CONCAT(p.first_name, ' ', p.last_name), m.message_text,
           m.file_object_name, m.file_url, m.file_type, m.file_size, m.is_read, m.created_at
    FROM chat_messages m JOIN profiles p ON p.id = m.sender_id
    WHERE m.conversation_id = p_conversation_id
    ORDER BY m.created_at DESC LIMIT p_limit OFFSET p_offset;
END; $$;

-- get_or_create_conversation
CREATE OR REPLACE FUNCTION chat_management.get_or_create_conversation(
    p_contract_id BIGINT, p_client_id BIGINT, p_freelancer_id BIGINT
)
RETURNS BIGINT LANGUAGE plpgsql AS $$
DECLARE v_conversation_id BIGINT;
BEGIN
    SELECT id INTO v_conversation_id FROM chat_conversations
    WHERE contract_id = p_contract_id OR (client_id = p_client_id AND freelancer_id = p_freelancer_id);
    
    IF v_conversation_id IS NULL THEN
        INSERT INTO chat_conversations (contract_id, client_id, freelancer_id)
        VALUES (p_contract_id, p_client_id, p_freelancer_id) RETURNING id INTO v_conversation_id;
    END IF;
    RETURN v_conversation_id;
END; $$;

-- send_message
CREATE OR REPLACE FUNCTION chat_management.send_message(
    p_conversation_id BIGINT, p_sender_id BIGINT, p_message_text TEXT,
    p_file_object_name VARCHAR(500) DEFAULT NULL, p_file_url VARCHAR(1000) DEFAULT NULL,
    p_file_type VARCHAR(50) DEFAULT NULL, p_file_size BIGINT DEFAULT NULL
)
RETURNS BIGINT LANGUAGE plpgsql AS $$
DECLARE v_message_id BIGINT; v_client_id BIGINT; v_freelancer_id BIGINT;
BEGIN
    SELECT client_id, freelancer_id INTO v_client_id, v_freelancer_id FROM chat_conversations WHERE id = p_conversation_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Conversation % not found', p_conversation_id; END IF;
    IF p_sender_id != v_client_id AND p_sender_id != v_freelancer_id THEN RAISE EXCEPTION 'User % is not a participant', p_sender_id; END IF;
    
    INSERT INTO chat_messages (conversation_id, sender_id, message_text, file_object_name, file_url, file_type, file_size)
    VALUES (p_conversation_id, p_sender_id, p_message_text, p_file_object_name, p_file_url, p_file_type, p_file_size)
    RETURNING id INTO v_message_id;
    
    UPDATE chat_conversations SET last_message_at = NOW() WHERE id = p_conversation_id;
    RETURN v_message_id;
END; $$;

-- mark_messages_as_read
CREATE OR REPLACE FUNCTION chat_management.mark_messages_as_read(p_conversation_id BIGINT, p_user_id BIGINT)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v_updated_count INTEGER;
BEGIN
    UPDATE chat_messages SET is_read = TRUE
    WHERE conversation_id = p_conversation_id AND sender_id != p_user_id AND is_read = FALSE;
    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    RETURN v_updated_count;
END; $$;

-- get_unread_count
CREATE OR REPLACE FUNCTION chat_management.get_unread_count(p_user_id BIGINT)
RETURNS INTEGER LANGUAGE plpgsql AS $$
DECLARE v_count INTEGER;
BEGIN
    SELECT COUNT(*)::INTEGER INTO v_count FROM chat_messages m
    JOIN chat_conversations c ON c.id = m.conversation_id
    WHERE (c.client_id = p_user_id OR c.freelancer_id = p_user_id)
      AND m.sender_id != p_user_id AND m.is_read = FALSE;
    RETURN COALESCE(v_count, 0);
END; $$;
