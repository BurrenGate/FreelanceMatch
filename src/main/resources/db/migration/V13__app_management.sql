-- V13: This script provides a set of general-purpose functions for application management,
-- primarily for administrative tasks and data retrieval.

CREATE SCHEMA IF NOT EXISTS app_management;

-- =============================================================================
-- Role Management Functions
-- =============================================================================

-- Function to get all user roles.
CREATE OR REPLACE FUNCTION app_management.get_roles()
RETURNS TABLE(id INTEGER, name VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT r.id, r.name FROM roles r ORDER BY r.id;
END;
$$;
COMMENT ON FUNCTION app_management.get_roles() IS 'Retrieves all user roles from the system.';

-- =============================================================================
-- Skill Management Functions
-- =============================================================================

-- Function to get all skills.
CREATE OR REPLACE FUNCTION app_management.get_skills()
RETURNS TABLE(id INTEGER, name VARCHAR, category VARCHAR)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT s.id, s.name, s.category FROM skills s ORDER BY s.name;
END;
$$;
COMMENT ON FUNCTION app_management.get_skills() IS 'Retrieves all available skills.';

-- Procedure to add or update a skill.
CREATE OR REPLACE PROCEDURE app_management.upsert_skill(
    p_skill_id INTEGER,
    p_name VARCHAR,
    p_category VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_skill_id IS NULL THEN
        INSERT INTO skills(name, category) VALUES (p_name, p_category);
    ELSE
        UPDATE skills SET name = p_name, category = p_category WHERE id = p_skill_id;
    END IF;
END;
$$;
COMMENT ON PROCEDURE app_management.upsert_skill(INTEGER, VARCHAR, VARCHAR)
IS 'Creates a new skill or updates an existing one.';

-- Procedure to delete a skill.
CREATE OR REPLACE PROCEDURE app_management.delete_skill(p_skill_id INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM skills WHERE id = p_skill_id;
END;
$$;
COMMENT ON PROCEDURE app_management.delete_skill(INTEGER)
IS 'Deletes a skill from the system.';

-- =============================================================================
-- Transaction Management Functions
-- =============================================================================

-- Function to get all transactions.
CREATE OR REPLACE FUNCTION app_management.get_transactions()
RETURNS TABLE(id BIGINT, contract_id BIGINT, amount DECIMAL, type VARCHAR, created_at TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT t.id, t.contract_id, t.amount, t.type, t.created_at FROM transactions t ORDER BY t.created_at DESC;
END;
$$;
COMMENT ON FUNCTION app_management.get_transactions() IS 'Retrieves all financial transactions.';

-- Function to get all transactions for a specific contract.
CREATE OR REPLACE FUNCTION app_management.get_transactions_by_contract(p_contract_id BIGINT)
RETURNS TABLE(id BIGINT, contract_id BIGINT, amount DECIMAL, type VARCHAR, created_at TIMESTAMP)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT t.id, t.contract_id, t.amount, t.type, t.created_at
    FROM transactions t WHERE t.contract_id = p_contract_id ORDER BY t.created_at DESC;
END;
$$;
COMMENT ON FUNCTION app_management.get_transactions_by_contract(BIGINT)
IS 'Retrieves all transactions associated with a specific contract.';

-- =============================================================================
-- Review Management Functions
-- =============================================================================

-- Function to get all reviews.
CREATE OR REPLACE FUNCTION app_management.get_reviews()
RETURNS TABLE(id BIGINT, contract_id BIGINT, reviewer_id BIGINT, rating INTEGER, comment TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT r.id, r.contract_id, r.reviewer_id, r.rating, r.comment FROM reviews r ORDER BY r.id DESC;
END;
$$;
COMMENT ON FUNCTION app_management.get_reviews() IS 'Retrieves all reviews from the system.';

-- Function to get all reviews for a specific contract.
CREATE OR REPLACE FUNCTION app_management.get_reviews_by_contract(p_contract_id BIGINT)
RETURNS TABLE(id BIGINT, contract_id BIGINT, reviewer_id BIGINT, rating INTEGER, comment TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT r.id, r.contract_id, r.reviewer_id, r.rating, r.comment
    FROM reviews r WHERE r.contract_id = p_contract_id ORDER BY r.id DESC;
END;
$$;
COMMENT ON FUNCTION app_management.get_reviews_by_contract(BIGINT)
IS 'Retrieves all reviews for a specific contract.';

-- Function to get all reviews submitted by a specific user.
CREATE OR REPLACE FUNCTION app_management.get_reviews_by_reviewer(p_reviewer_id BIGINT)
RETURNS TABLE(id BIGINT, contract_id BIGINT, reviewer_id BIGINT, rating INTEGER, comment TEXT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY SELECT r.id, r.contract_id, r.reviewer_id, r.rating, r.comment
    FROM reviews r WHERE r.reviewer_id = p_reviewer_id ORDER BY r.id DESC;
END;
$$;
COMMENT ON FUNCTION app_management.get_reviews_by_reviewer(BIGINT)
IS 'Retrieves all reviews submitted by a specific user.';
