-- V43: Fix chat partners to show all people with any job history

-- Drop old function first
DROP FUNCTION IF EXISTS chat_management.get_available_chat_partners(BIGINT);

-- Function to get available chat partners (all people with job history)
CREATE FUNCTION chat_management.get_available_chat_partners(
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

COMMENT ON FUNCTION chat_management.get_available_chat_partners IS 'Get all people user has job/proposal history with';
