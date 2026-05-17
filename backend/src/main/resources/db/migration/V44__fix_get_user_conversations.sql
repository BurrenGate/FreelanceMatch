-- V44: Fix get_user_conversations function

-- Drop and recreate get_user_conversations
DROP FUNCTION IF EXISTS chat_management.get_user_conversations(BIGINT);

CREATE FUNCTION chat_management.get_user_conversations(
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

COMMENT ON FUNCTION chat_management.get_user_conversations IS 'Get all conversations for a user';
