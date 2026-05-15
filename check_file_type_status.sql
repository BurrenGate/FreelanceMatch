-- Diagnostic script: Check file_type column status
-- Run this to see if V48 migration is needed or already applied

\echo '=========================================='
\echo 'FreelanceMatch - file_type Column Status'
\echo '=========================================='
\echo ''

-- 1. Check Flyway migration status
\echo '1. Flyway Migration Status:'
\echo '----------------------------'
SELECT 
    version,
    description,
    type,
    installed_on,
    success
FROM flyway_schema_history
WHERE version IN ('47', '48')
ORDER BY version;

\echo ''

-- 2. Check current column definition
\echo '2. Current file_type Column Definition:'
\echo '----------------------------------------'
SELECT 
    table_name,
    column_name,
    data_type,
    character_maximum_length,
    CASE 
        WHEN character_maximum_length >= 255 THEN '✅ OK - Can handle long MIME types'
        WHEN character_maximum_length = 50 THEN '❌ PROBLEM - Too short for Office files'
        ELSE '⚠️  UNKNOWN'
    END AS status
FROM information_schema.columns
WHERE table_name = 'chat_messages' 
  AND column_name = 'file_type';

\echo ''

-- 3. Check function signature
\echo '3. send_message Function Signature:'
\echo '------------------------------------'
SELECT 
    p.proname AS function_name,
    pg_get_function_arguments(p.oid) AS arguments
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'chat_management'
  AND p.proname = 'send_message';

\echo ''

-- 4. Test with sample long MIME types
\echo '4. MIME Type Length Test:'
\echo '--------------------------'
WITH mime_types AS (
    SELECT 'image/jpeg' AS mime_type, 'JPEG Image' AS description
    UNION ALL SELECT 'application/pdf', 'PDF Document'
    UNION ALL SELECT 'application/vnd.openxmlformats-officedocument.wordprocessingml.document', 'Word Document (.docx)'
    UNION ALL SELECT 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'Excel Spreadsheet (.xlsx)'
    UNION ALL SELECT 'application/vnd.openxmlformats-officedocument.presentationml.presentation', 'PowerPoint (.pptx)'
)
SELECT 
    description,
    LENGTH(mime_type) AS length,
    CASE 
        WHEN LENGTH(mime_type) <= 50 THEN '✅ Works with VARCHAR(50)'
        WHEN LENGTH(mime_type) <= 255 THEN '⚠️  Needs VARCHAR(255)'
        ELSE '❌ Too long even for VARCHAR(255)'
    END AS compatibility,
    mime_type
FROM mime_types
ORDER BY LENGTH(mime_type) DESC;

\echo ''

-- 5. Check existing messages with file types
\echo '5. Existing Messages Statistics:'
\echo '---------------------------------'
SELECT 
    COUNT(*) AS total_messages,
    COUNT(file_type) AS messages_with_files,
    COUNT(DISTINCT file_type) AS unique_file_types,
    MAX(LENGTH(file_type)) AS max_file_type_length
FROM chat_messages;

\echo ''

-- 6. Show actual file types in use
\echo '6. File Types Currently in Database:'
\echo '-------------------------------------'
SELECT 
    file_type,
    LENGTH(file_type) AS length,
    COUNT(*) AS count,
    CASE 
        WHEN LENGTH(file_type) > 50 THEN '⚠️  Would fail with VARCHAR(50)'
        ELSE '✅ OK'
    END AS status
FROM chat_messages
WHERE file_type IS NOT NULL
GROUP BY file_type
ORDER BY LENGTH(file_type) DESC, count DESC;

\echo ''

-- 7. Recommendation
\echo '7. Recommendation:'
\echo '-------------------'
DO $$
DECLARE
    v_current_length INTEGER;
    v_migration_applied BOOLEAN;
BEGIN
    -- Check current column length
    SELECT character_maximum_length INTO v_current_length
    FROM information_schema.columns
    WHERE table_name = 'chat_messages' 
      AND column_name = 'file_type';
    
    -- Check if V48 migration is applied
    SELECT EXISTS(
        SELECT 1 FROM flyway_schema_history 
        WHERE version = '48' AND success = true
    ) INTO v_migration_applied;
    
    IF v_current_length >= 255 THEN
        RAISE NOTICE '✅ GOOD: file_type column is VARCHAR(%) - All MIME types supported', v_current_length;
        RAISE NOTICE '✅ V48 migration is applied: %', v_migration_applied;
        RAISE NOTICE '';
        RAISE NOTICE '👍 No action needed. System is ready for all file types.';
    ELSIF v_current_length = 50 THEN
        RAISE NOTICE '❌ PROBLEM: file_type column is VARCHAR(50) - Office files will fail';
        RAISE NOTICE '❌ V48 migration is applied: %', v_migration_applied;
        RAISE NOTICE '';
        RAISE NOTICE '🔧 ACTION REQUIRED:';
        RAISE NOTICE '   1. Run: ./apply_file_type_fix.sh';
        RAISE NOTICE '   2. Or restart app: docker-compose restart app';
        RAISE NOTICE '   3. Or apply manually: \i src/main/resources/db/migration/V48__fix_chat_file_type_length.sql';
    ELSE
        RAISE NOTICE '⚠️  UNKNOWN: file_type column is VARCHAR(%) - Unexpected length', v_current_length;
        RAISE NOTICE '   Please check the schema manually.';
    END IF;
END $$;

\echo ''
\echo '=========================================='
\echo 'Diagnostic Complete'
\echo '=========================================='
