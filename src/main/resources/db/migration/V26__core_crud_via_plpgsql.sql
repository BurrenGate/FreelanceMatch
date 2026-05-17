CREATE SCHEMA IF NOT EXISTS app_management;

CREATE OR REPLACE FUNCTION app_management.get_roles()
RETURNS TABLE(
    id INTEGER,
    name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.name
    FROM roles r
    ORDER BY r.id;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_role_by_id(
    p_role_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.name
    FROM roles r
    WHERE r.id = p_role_id;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_role_by_name(
    p_name VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.name
    FROM roles r
    WHERE LOWER(r.name) = LOWER(p_name);
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_skills()
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    category VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.name, s.category
    FROM skills s
    ORDER BY s.name;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_skill_by_id(
    p_skill_id INTEGER
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    category VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.name, s.category
    FROM skills s
    WHERE s.id = p_skill_id;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_skills_by_category(
    p_category VARCHAR
)
RETURNS TABLE(
    id INTEGER,
    name VARCHAR,
    category VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.name, s.category
    FROM skills s
    WHERE s.category = p_category
    ORDER BY s.name;
END;
$$;

CREATE OR REPLACE PROCEDURE app_management.upsert_skill(
    p_skill_id INTEGER,
    p_name VARCHAR,
    p_category VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_skill_id IS NULL THEN
        INSERT INTO skills(name, category)
        VALUES (p_name, p_category);
    ELSE
        UPDATE skills
        SET name = p_name,
            category = p_category
        WHERE skills.id = p_skill_id;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE app_management.delete_skill(
    p_skill_id INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM skills
    WHERE skills.id = p_skill_id;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_transactions()
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    amount DECIMAL,
    type VARCHAR,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.contract_id, t.amount, t.type, t.created_at
    FROM transactions t
    ORDER BY t.created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_transaction_by_id(
    p_transaction_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    amount DECIMAL,
    type VARCHAR,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.contract_id, t.amount, t.type, t.created_at
    FROM transactions t
    WHERE t.id = p_transaction_id;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_transactions_by_contract(
    p_contract_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    amount DECIMAL,
    type VARCHAR,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.contract_id, t.amount, t.type, t.created_at
    FROM transactions t
    WHERE t.contract_id = p_contract_id
    ORDER BY t.created_at DESC;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_transactions_by_type(
    p_type VARCHAR
)
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    amount DECIMAL,
    type VARCHAR,
    created_at TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT t.id, t.contract_id, t.amount, t.type, t.created_at
    FROM transactions t
    WHERE t.type = p_type
    ORDER BY t.created_at DESC;
END;
$$;

CREATE OR REPLACE PROCEDURE app_management.upsert_transaction(
    p_transaction_id BIGINT,
    p_contract_id BIGINT,
    p_amount DECIMAL,
    p_type VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_transaction_id IS NULL THEN
        INSERT INTO transactions(contract_id, amount, type)
        VALUES (p_contract_id, p_amount, p_type);
    ELSE
        UPDATE transactions
        SET contract_id = p_contract_id,
            amount = p_amount,
            type = p_type
        WHERE transactions.id = p_transaction_id;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE app_management.delete_transaction(
    p_transaction_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM transactions
    WHERE transactions.id = p_transaction_id;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_reviews()
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    reviewer_id BIGINT,
    rating INTEGER,
    comment TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.contract_id, r.reviewer_id, r.rating, r.comment
    FROM reviews r
    ORDER BY r.id DESC;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_review_by_id(
    p_review_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    reviewer_id BIGINT,
    rating INTEGER,
    comment TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.contract_id, r.reviewer_id, r.rating, r.comment
    FROM reviews r
    WHERE r.id = p_review_id;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_reviews_by_contract(
    p_contract_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    reviewer_id BIGINT,
    rating INTEGER,
    comment TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.contract_id, r.reviewer_id, r.rating, r.comment
    FROM reviews r
    WHERE r.contract_id = p_contract_id
    ORDER BY r.id DESC;
END;
$$;

CREATE OR REPLACE FUNCTION app_management.get_reviews_by_reviewer(
    p_reviewer_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    contract_id BIGINT,
    reviewer_id BIGINT,
    rating INTEGER,
    comment TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT r.id, r.contract_id, r.reviewer_id, r.rating, r.comment
    FROM reviews r
    WHERE r.reviewer_id = p_reviewer_id
    ORDER BY r.id DESC;
END;
$$;

CREATE OR REPLACE PROCEDURE app_management.upsert_review(
    p_review_id BIGINT,
    p_contract_id BIGINT,
    p_reviewer_id BIGINT,
    p_rating INTEGER,
    p_comment TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_review_id IS NULL THEN
        INSERT INTO reviews(contract_id, reviewer_id, rating, comment)
        VALUES (p_contract_id, p_reviewer_id, p_rating, p_comment);
    ELSE
        UPDATE reviews
        SET contract_id = p_contract_id,
            reviewer_id = p_reviewer_id,
            rating = p_rating,
            comment = p_comment
        WHERE reviews.id = p_review_id;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE app_management.delete_review(
    p_review_id BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM reviews
    WHERE reviews.id = p_review_id;
END;
$$;
