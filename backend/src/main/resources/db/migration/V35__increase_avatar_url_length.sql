-- V35: Increase avatar_url length to support long MinIO URLs

ALTER TABLE profiles ALTER COLUMN avatar_url TYPE VARCHAR(1000);

COMMENT ON COLUMN profiles.avatar_url IS 'Avatar URL (supports long MinIO presigned URLs)';
