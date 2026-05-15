-- V50: Fix skill_management schema access
-- Grant permissions and set search_path

-- Grant usage on schema
GRANT USAGE ON SCHEMA skill_management TO PUBLIC;

-- Grant execute on all functions in skill_management schema
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA skill_management TO PUBLIC;

-- Set default privileges for future functions
ALTER DEFAULT PRIVILEGES IN SCHEMA skill_management GRANT EXECUTE ON FUNCTIONS TO PUBLIC;

-- Update search_path for the database user
ALTER DATABASE freelance SET search_path TO public, skill_management;
