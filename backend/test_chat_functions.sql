-- Test script to verify chat functions exist

-- Check if schema exists
SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'chat_management';

-- Check if functions exist
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_schema = 'chat_management'
ORDER BY routine_name;

-- Try to call the function
SELECT * FROM chat_management.get_user_conversations(1) LIMIT 1;
