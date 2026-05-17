-- V48: Fix file_type column length in chat_messages table
-- Problem: VARCHAR(50) is too short for MIME types like 
-- 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'

-- Increase file_type column length to accommodate long MIME types
ALTER TABLE chat_messages 
ALTER COLUMN file_type TYPE VARCHAR(255);

-- Update function signature to match new column type
CREATE OR REPLACE FUNCTION chat_management.send_message(
    p_conversation_id BIGINT,
    p_sender_id BIGINT,
    p_message_text TEXT,
    p_file_object_name VARCHAR(500) DEFAULT NULL,
    p_file_url VARCHAR(1000) DEFAULT NULL,
    p_file_type VARCHAR(255) DEFAULT NULL,
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

-- Update get_conversation_messages function return type
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
    file_type VARCHAR(255),
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

COMMENT ON COLUMN chat_messages.file_type IS 'MIME type of uploaded file (e.g., application/pdf, image/jpeg)';
