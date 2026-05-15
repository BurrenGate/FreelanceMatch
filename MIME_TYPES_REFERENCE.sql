-- MIME Types Reference for FreelanceMatch Chat System
-- After V48 migration: file_type column supports VARCHAR(255)

-- ============================================
-- SUPPORTED MIME TYPES
-- ============================================

-- DOCUMENTS (Office, PDF, Text)
-- ============================================
-- PDF
'application/pdf'                                                                    -- .pdf (15 chars)

-- Microsoft Word
'application/msword'                                                                 -- .doc (19 chars)
'application/vnd.openxmlformats-officedocument.wordprocessingml.document'          -- .docx (73 chars) ⚠️ LONG

-- Microsoft Excel
'application/vnd.ms-excel'                                                          -- .xls (25 chars)
'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'                -- .xlsx (66 chars) ⚠️ LONG

-- Microsoft PowerPoint
'application/vnd.ms-powerpoint'                                                     -- .ppt (30 chars)
'application/vnd.openxmlformats-officedocument.presentationml.presentation'        -- .pptx (74 chars) ⚠️ LONGEST

-- Text files
'text/plain'                                                                        -- .txt (10 chars)
'text/csv'                                                                          -- .csv (8 chars)
'text/html'                                                                         -- .html (9 chars)

-- Rich Text
'application/rtf'                                                                   -- .rtf (15 chars)

-- OpenDocument
'application/vnd.oasis.opendocument.text'                                          -- .odt (41 chars)
'application/vnd.oasis.opendocument.spreadsheet'                                   -- .ods (48 chars)
'application/vnd.oasis.opendocument.presentation'                                  -- .odp (49 chars)


-- IMAGES
-- ============================================
'image/jpeg'                                                                        -- .jpg, .jpeg (10 chars)
'image/png'                                                                         -- .png (9 chars)
'image/gif'                                                                         -- .gif (9 chars)
'image/webp'                                                                        -- .webp (10 chars)
'image/svg+xml'                                                                     -- .svg (13 chars)
'image/bmp'                                                                         -- .bmp (9 chars)
'image/tiff'                                                                        -- .tiff (10 chars)
'image/x-icon'                                                                      -- .ico (12 chars)


-- VIDEO
-- ============================================
'video/mp4'                                                                         -- .mp4 (9 chars)
'video/webm'                                                                        -- .webm (10 chars)
'video/ogg'                                                                         -- .ogv (9 chars)
'video/quicktime'                                                                   -- .mov (15 chars)
'video/x-msvideo'                                                                   -- .avi (15 chars)
'video/x-matroska'                                                                  -- .mkv (16 chars)


-- AUDIO
-- ============================================
'audio/mpeg'                                                                        -- .mp3 (10 chars)
'audio/wav'                                                                         -- .wav (9 chars)
'audio/ogg'                                                                         -- .ogg (9 chars)
'audio/webm'                                                                        -- .weba (10 chars)
'audio/aac'                                                                         -- .aac (9 chars)
'audio/x-m4a'                                                                       -- .m4a (11 chars)


-- ARCHIVES
-- ============================================
'application/zip'                                                                   -- .zip (15 chars)
'application/x-rar-compressed'                                                      -- .rar (30 chars)
'application/x-7z-compressed'                                                       -- .7z (28 chars)
'application/x-tar'                                                                 -- .tar (17 chars)
'application/gzip'                                                                  -- .gz (16 chars)


-- CODE & DEVELOPMENT
-- ============================================
'application/json'                                                                  -- .json (16 chars)
'application/xml'                                                                   -- .xml (15 chars)
'text/javascript'                                                                   -- .js (15 chars)
'text/css'                                                                          -- .css (8 chars)
'application/x-sql'                                                                 -- .sql (17 chars)


-- OTHER
-- ============================================
'application/octet-stream'                                                          -- binary/unknown (24 chars)


-- ============================================
-- VALIDATION QUERY
-- ============================================
-- Check if a MIME type fits in the column
SELECT 
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' AS mime_type,
    LENGTH('application/vnd.openxmlformats-officedocument.presentationml.presentation') AS length,
    CASE 
        WHEN LENGTH('application/vnd.openxmlformats-officedocument.presentationml.presentation') <= 255 
        THEN '✅ FITS' 
        ELSE '❌ TOO LONG' 
    END AS status;


-- ============================================
-- STATISTICS
-- ============================================
-- Before V48: VARCHAR(50)  - ❌ Failed for 3 common types
-- After V48:  VARCHAR(255) - ✅ Supports all standard MIME types
--
-- Longest standard MIME types:
-- 1. PowerPoint (.pptx) - 74 chars
-- 2. Word (.docx)       - 73 chars  
-- 3. Excel (.xlsx)      - 66 chars
--
-- All fit comfortably in VARCHAR(255)


-- ============================================
-- USAGE IN APPLICATION
-- ============================================
/*
Java code example:

String mimeType = "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
Long messageId = chatRepository.sendMessage(
    conversationId,
    senderId,
    "Sending Word document",
    "report.docx",
    "http://localhost:9000/freelancematch/report.docx",
    mimeType,  // ✅ Now works! (was failing before V48)
    1024000L
);
*/
