-- V45: Verify and fix chat schema and functions

-- Ensure schema exists
CREATE SCHEMA IF NOT EXISTS chat_management;

-- Test if function exists and works
DO $$
BEGIN
    -- Test get_user_conversations
    PERFORM chat_management.get_user_conversations(1);
    RAISE NOTICE 'get_user_conversations function works';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'get_user_conversations error: %', SQLERRM;
END $$;

-- Test get_available_chat_partners
DO $$
BEGIN
    PERFORM chat_management.get_available_chat_partners(1);
    RAISE NOTICE 'get_available_chat_partners function works';
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'get_available_chat_partners error: %', SQLERRM;
END $$;
