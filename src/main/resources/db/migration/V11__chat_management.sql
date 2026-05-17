-- V11: This script sets up the real-time chat functionality, including tables for
-- conversations and messages, and the business logic for managing them.

CREATE SCHEMA IF NOT EXISTS chat_management;

-- Add indexes for performance.
CREATE INDEX IF NOT EXISTS idx_chat_conversations_client ON chat_conversations(client_id);
CREATE INDEX IF NOT EXISTS idx_chat_conversations_freelancer ON chat_conversations(freelancer_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_conversation ON chat_messages(conversation_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created ON chat_messages(created_at DESC);

-- Trigger to automatically create a chat conversation when a contract is created.
CREATE OR REPLACE FUNCTION chat_management.auto_create_conversation_on_contract()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_client_id BIGINT;
BEGIN
    SELECT client_id INTO v_client_id FROM jobs WHERE id = NEW.job_id;

    IF NOT EXISTS (SELECT 1 FROM chat_conversations WHERE contract_id = NEW.id) THEN
        INSERT INTO chat_conversations (contract_id, client_id, freelancer_id)
        VALUES (NEW.id, v_client_id, NEW.freelancer_id);
        RAISE NOTICE 'Automatically created conversation for contract %.', NEW.id;
    END IF;

    RETURN NEW;
END;
$$;
DROP TRIGGER IF EXISTS trigger_auto_create_conversation ON contracts;
CREATE TRIGGER trigger_auto_create_conversation
    AFTER INSERT ON contracts
    FOR EACH ROW
    EXECUTE FUNCTION chat_management.auto_create_conversation_on_contract();
COMMENT ON TRIGGER trigger_auto_create_conversation ON contracts
IS 'Ensures a chat conversation is created automatically when a new contract is formed.';

-- Function to get all conversations for a specific user.
CREATE OR REPLACE FUNCTION chat_management.get_user_conversations(p_user_id BIGINT)
RETURNS TABLE (
    conversation_id BIGINT,
    contract_id BIGINT,
    other_user_id BIGINT,
    other_user_name TEXT,
    other_user_avatar VARCHAR(1000),
    last_message_text TEXT,
    last_message_at TIMESTAMP,
    unread_count BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id,
        c.contract_id,
        CASE WHEN c.client_id = p_user_id THEN c.freelancer_id ELSE c.client_id END,
        CASE WHEN c.client_id = p_user_id THEN (fp.first_name || ' ' || fp.last_name)::TEXT ELSE (cp.first_name || ' ' || cp.last_name)::TEXT END,
        CASE WHEN c.client_id = p_user_id THEN fp.avatar_url ELSE cp.avatar_url END,
        (SELECT m.message_text FROM chat_messages m WHERE m.conversation_id = c.id ORDER BY m.created_at DESC LIMIT 1),
        c.last_message_at,
        (SELECT COUNT(*) FROM chat_messages m WHERE m.conversation_id = c.id AND m.sender_id != p_user_id AND m.is_read = FALSE)
    FROM chat_conversations c
    JOIN profiles cp ON cp.id = c.client_id
    JOIN profiles fp ON fp.id = c.freelancer_id
    WHERE c.client_id = p_user_id OR c.freelancer_id = p_user_id
    ORDER BY c.last_message_at DESC;
END;
$$;
COMMENT ON FUNCTION chat_management.get_user_conversations(BIGINT)
IS 'Retrieves a list of all conversations for a given user, along with metadata about the last message and unread count.';

-- Function to get messages from a specific conversation.
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
    file_url VARCHAR(1000),
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    -- First, verify the user is a participant in the conversation.
    IF NOT EXISTS (SELECT 1 FROM chat_conversations WHERE id = p_conversation_id AND (client_id = p_user_id OR freelancer_id = p_user_id)) THEN
        RAISE EXCEPTION 'User % is not a participant of conversation %.', p_user_id, p_conversation_id;
    END IF;

    -- Then, return the messages.
    RETURN QUERY
    SELECT
        m.id,
        m.sender_id,
        (p.first_name || ' ' || p.last_name)::TEXT,
        m.message_text,
        m.file_url,
        m.created_at
    FROM chat_messages m
    JOIN profiles p ON p.id = m.sender_id
    WHERE m.conversation_id = p_conversation_id
    ORDER BY m.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$;
COMMENT ON FUNCTION chat_management.get_conversation_messages(BIGINT, BIGINT, INTEGER, INTEGER)
IS 'Retrieves a paginated list of messages from a conversation, ensuring the user is a participant.';

-- Function to send a new message in a conversation.
CREATE OR REPLACE FUNCTION chat_management.send_message(
    p_conversation_id BIGINT,
    p_sender_id BIGINT,
    p_message_text TEXT,
    p_file_url VARCHAR(1000) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_message_id BIGINT;
BEGIN
    -- Verify the sender is a participant.
    IF NOT EXISTS (SELECT 1 FROM chat_conversations WHERE id = p_conversation_id AND (client_id = p_sender_id OR freelancer_id = p_sender_id)) THEN
        RAISE EXCEPTION 'User % is not a participant of conversation %.', p_sender_id, p_conversation_id;
    END IF;

    -- Insert the new message.
    INSERT INTO chat_messages (conversation_id, sender_id, message_text, file_url)
    VALUES (p_conversation_id, p_sender_id, p_message_text, p_file_url)
    RETURNING id INTO v_message_id;

    -- Update the `last_message_at` timestamp on the conversation.
    UPDATE chat_conversations SET last_message_at = NOW() WHERE id = p_conversation_id;

    RETURN v_message_id;
END;
$$;
COMMENT ON FUNCTION chat_management.send_message(BIGINT, BIGINT, TEXT, VARCHAR)
IS 'Sends a new message in a conversation and updates the conversation''s last message timestamp.';

-- Function to mark all unread messages in a conversation as read for a user.
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
    UPDATE chat_messages
    SET is_read = TRUE
    WHERE conversation_id = p_conversation_id
      AND sender_id != p_user_id
      AND is_read = FALSE;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;
    RETURN v_updated_count;
END;
$$;
COMMENT ON FUNCTION chat_management.mark_messages_as_read(BIGINT, BIGINT)
IS 'Marks all messages in a conversation as read for the specified user.';

-- Function to get the total number of unread messages for a user across all conversations.
CREATE OR REPLACE FUNCTION chat_management.get_unread_count(p_user_id BIGINT)
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
COMMENT ON FUNCTION chat_management.get_unread_count(BIGINT)
IS 'Calculates the total number of unread messages for a user across all of their conversations.';
