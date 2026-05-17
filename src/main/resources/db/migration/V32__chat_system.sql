-- V32: Chat system between clients and freelancers

-- Create schema for chat management
CREATE SCHEMA IF NOT EXISTS chat_management;

-- Table for chat conversations
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

-- Table for chat messages
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

-- Indexes for performance
CREATE INDEX idx_chat_conversations_client ON chat_conversations(client_id);
CREATE INDEX idx_chat_conversations_freelancer ON chat_conversations(freelancer_id);
CREATE INDEX idx_chat_conversations_contract ON chat_conversations(contract_id);
CREATE INDEX idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX idx_chat_messages_sender ON chat_messages(sender_id);
CREATE INDEX idx_chat_messages_created ON chat_messages(created_at DESC);
CREATE INDEX idx_chat_messages_unread ON chat_messages(is_read) WHERE is_read = FALSE;

-- Function to get or create conversation
CREATE OR REPLACE FUNCTION chat_management.get_or_create_conversation(
    p_contract_id BIGINT,
    p_client_id BIGINT,
    p_freelancer_id BIGINT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_conversation_id BIGINT;
BEGIN
    -- Try to find existing conversation
    SELECT id INTO v_conversation_id
    FROM chat_conversations
    WHERE contract_id = p_contract_id
       OR (client_id = p_client_id AND freelancer_id = p_freelancer_id);
    
    -- If not found, create new conversation
    IF v_conversation_id IS NULL THEN
        INSERT INTO chat_conversations (contract_id, client_id, freelancer_id)
        VALUES (p_contract_id, p_client_id, p_freelancer_id)
        RETURNING id INTO v_conversation_id;
        
        RAISE NOTICE 'Created new conversation %', v_conversation_id;
    END IF;
    
    RETURN v_conversation_id;
END;
$$;

-- Function to send message
CREATE OR REPLACE FUNCTION chat_management.send_message(
    p_conversation_id BIGINT,
    p_sender_id BIGINT,
    p_message_text TEXT,
    p_file_object_name VARCHAR(500) DEFAULT NULL,
    p_file_url VARCHAR(1000) DEFAULT NULL,
    p_file_type VARCHAR(50) DEFAULT NULL,
    p_file_size BIGINT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_message_id BIGINT;
    v_client_id BIGINT;
    v_freelancer_id BIGINT;
BEGIN
    -- Verify conversation exists and sender is participant
    SELECT client_id, freelancer_id INTO v_client_id, v_freelancer_id
    FROM chat_conversations
    WHERE id = p_conversation_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Conversation % not found', p_conversation_id;
    END IF;
    
    IF p_sender_id != v_client_id AND p_sender_id != v_freelancer_id THEN
        RAISE EXCEPTION 'User % is not a participant of conversation %', p_sender_id, p_conversation_id;
    END IF;
    
    -- Insert message
    INSERT INTO chat_messages (
        conversation_id,
        sender_id,
        message_text,
        file_object_name,
        file_url,
        file_type,
        file_size
    )
    VALUES (
        p_conversation_id,
        p_sender_id,
        p_message_text,
        p_file_object_name,
        p_file_url,
        p_file_type,
        p_file_size
    )
    RETURNING id INTO v_message_id;
    
    -- Update last_message_at in conversation
    UPDATE chat_conversations
    SET last_message_at = NOW()
    WHERE id = p_conversation_id;
    
    RETURN v_message_id;
END;
$$;

-- Function to get conversation messages
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

-- Function to get user conversations
CREATE OR REPLACE FUNCTION chat_management.get_user_conversations(
    p_user_id BIGINT
)
RETURNS TABLE (
    conversation_id BIGINT,
    contract_id BIGINT,
    other_user_id BIGINT,
    other_user_name TEXT,
    other_user_avatar VARCHAR(255),
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

-- Function to mark messages as read
CREATE OR REPLACE FUNCTION chat_management.mark_messages_as_read(
    p_conversation_id BIGINT,
    p_user_id BIGINT
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_updated_count INTEGER;
BEGIN
    -- Mark all messages from other user as read
    UPDATE chat_messages
    SET is_read = TRUE
    WHERE conversation_id = p_conversation_id
      AND sender_id != p_user_id
      AND is_read = FALSE;
    
    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    
    RETURN v_updated_count;
END;
$$;

-- Function to get unread messages count
CREATE OR REPLACE FUNCTION chat_management.get_unread_count(
    p_user_id BIGINT
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*)::INTEGER INTO v_count
    FROM chat_messages m
    JOIN chat_conversations c ON c.id = m.conversation_id
    WHERE (c.client_id = p_user_id OR c.freelancer_id = p_user_id)
      AND m.sender_id != p_user_id
      AND m.is_read = FALSE;
    
    RETURN COALESCE(v_count, 0);
END;
$$;

COMMENT ON TABLE chat_conversations IS 'Chat conversations between clients and freelancers';
COMMENT ON TABLE chat_messages IS 'Messages in chat conversations with support for text and files';
COMMENT ON FUNCTION chat_management.get_or_create_conversation IS 'Get existing or create new conversation';
COMMENT ON FUNCTION chat_management.send_message IS 'Send a message in conversation';
COMMENT ON FUNCTION chat_management.get_conversation_messages IS 'Get messages from conversation';
COMMENT ON FUNCTION chat_management.get_user_conversations IS 'Get all conversations for a user';
COMMENT ON FUNCTION chat_management.mark_messages_as_read IS 'Mark messages as read';
COMMENT ON FUNCTION chat_management.get_unread_count IS 'Get total unread messages count for user';
