-- Run this script manually in your PostgreSQL database to fix V29 migration issue
-- Execute: psql -h localhost -U user -d freelance -f fix_v29_migration.sql

-- Drop existing functions that have changed return types
DROP FUNCTION IF EXISTS job_market.get_freelancer_reviews(BIGINT, INTEGER);
DROP FUNCTION IF EXISTS job_market.get_freelancer_profile(BIGINT);

-- Delete V29 from flyway history if it exists (so it can be re-run)
DELETE FROM flyway_schema_history WHERE version = '29';

-- Verify
SELECT version, description, success FROM flyway_schema_history ORDER BY installed_rank DESC LIMIT 5;
