-- Test script for V48 migration: Fix file_type column length

-- 1. Check current column definition
SELECT 
    column_name, 
    data_type, 
    character_maximum_length
FROM information_schema.columns
WHERE table_name = 'chat_messages' 
  AND column_name = 'file_type';

-- Expected result after migration:
-- column_name | data_type        | character_maximum_length
-- file_type   | character varying| 255

-- 2. Test with long MIME type (should work after migration)
-- Example: Microsoft Word document MIME type
DO $$
DECLARE
    v_conversation_id BIGINT;
    v_message_id BIGINT;
    v_long_mime_type VARCHAR(255) := 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
BEGIN
    -- Get any existing conversation or create test data
    SELECT id INTO v_conversation_id 
    FROM chat_conversations 
    LIMIT 1;
    
    IF v_conversation_id IS NOT NULL THEN
        -- Test sending message with long MIME type
        SELECT chat_management.send_message(
            v_conversation_id,
            (SELECT client_id FROM chat_conversations WHERE id = v_conversation_id),
            'Test message with long MIME type',
            'test-document.docx',
            'http://localhost:9000/freelancematch/test-document.docx',
            v_long_mime_type,
            1024000
        ) INTO v_message_id;
        
        RAISE NOTICE 'Successfully created message % with MIME type length: %', 
                     v_message_id, LENGTH(v_long_mime_type);
        
        -- Clean up test message
        DELETE FROM chat_messages WHERE id = v_message_id;
        RAISE NOTICE 'Test message cleaned up';
    ELSE
        RAISE NOTICE 'No conversations found for testing. Create a conversation first.';
    END IF;
END $$;

-- 3. Common long MIME types that should now work:
-- application/vnd.openxmlformats-officedocument.wordprocessingml.document (73 chars) - Word
-- application/vnd.openxmlformats-officedocument.spreadsheetml.sheet (66 chars) - Excel
-- application/vnd.openxmlformats-officedocument.presentationml.presentation (74 chars) - PowerPoint
-- application/vnd.ms-excel.sheet.macroEnabled.12 (47 chars) - Excel with macros

COMMENT ON COLUMN chat_messages.file_type IS 'MIME type of uploaded file - increased to VARCHAR(255) to support long MIME types';
