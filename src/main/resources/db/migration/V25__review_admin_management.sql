CREATE OR REPLACE FUNCTION admin_management.get_reviews(
    p_contract_id BIGINT,
    p_reviewer_id BIGINT,
    p_admin_email VARCHAR
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
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    RETURN QUERY
    SELECT r.id, r.contract_id, r.reviewer_id, r.rating, r.comment
    FROM reviews r
    WHERE (p_contract_id IS NULL OR r.contract_id = p_contract_id)
      AND (p_reviewer_id IS NULL OR r.reviewer_id = p_reviewer_id)
    ORDER BY r.id DESC;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.get_review_by_id(
    p_review_id BIGINT,
    p_admin_email VARCHAR
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
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF NOT EXISTS (SELECT 1 FROM reviews WHERE reviews.id = p_review_id) THEN
        RAISE EXCEPTION 'Review % not found', p_review_id;
    END IF;

    RETURN QUERY
    SELECT r.id, r.contract_id, r.reviewer_id, r.rating, r.comment
    FROM reviews r
    WHERE r.id = p_review_id;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.create_review(
    p_contract_id BIGINT,
    p_reviewer_id BIGINT,
    p_rating INTEGER,
    p_comment TEXT,
    p_admin_email VARCHAR
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
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF p_contract_id IS NULL OR NOT EXISTS (SELECT 1 FROM contracts WHERE contracts.id = p_contract_id) THEN
        RAISE EXCEPTION 'Contract % not found', p_contract_id;
    END IF;

    IF p_reviewer_id IS NULL OR NOT EXISTS (SELECT 1 FROM profiles WHERE profiles.id = p_reviewer_id) THEN
        RAISE EXCEPTION 'Reviewer profile % not found', p_reviewer_id;
    END IF;

    IF p_rating IS NULL OR p_rating < 1 OR p_rating > 5 THEN
        RAISE EXCEPTION 'Rating must be between 1 and 5';
    END IF;

    RETURN QUERY
    INSERT INTO reviews(contract_id, reviewer_id, rating, comment)
    VALUES (p_contract_id, p_reviewer_id, p_rating, p_comment)
    RETURNING reviews.id, reviews.contract_id, reviews.reviewer_id, reviews.rating, reviews.comment;
END;
$$;

CREATE OR REPLACE FUNCTION admin_management.update_review(
    p_review_id BIGINT,
    p_contract_id BIGINT,
    p_reviewer_id BIGINT,
    p_rating INTEGER,
    p_comment TEXT,
    p_admin_email VARCHAR
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
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF NOT EXISTS (SELECT 1 FROM reviews WHERE reviews.id = p_review_id) THEN
        RAISE EXCEPTION 'Review % not found', p_review_id;
    END IF;

    IF p_contract_id IS NULL OR NOT EXISTS (SELECT 1 FROM contracts WHERE contracts.id = p_contract_id) THEN
        RAISE EXCEPTION 'Contract % not found', p_contract_id;
    END IF;

    IF p_reviewer_id IS NULL OR NOT EXISTS (SELECT 1 FROM profiles WHERE profiles.id = p_reviewer_id) THEN
        RAISE EXCEPTION 'Reviewer profile % not found', p_reviewer_id;
    END IF;

    IF p_rating IS NULL OR p_rating < 1 OR p_rating > 5 THEN
        RAISE EXCEPTION 'Rating must be between 1 and 5';
    END IF;

    RETURN QUERY
    UPDATE reviews
    SET contract_id = p_contract_id,
        reviewer_id = p_reviewer_id,
        rating = p_rating,
        comment = p_comment
    WHERE reviews.id = p_review_id
    RETURNING reviews.id, reviews.contract_id, reviews.reviewer_id, reviews.rating, reviews.comment;
END;
$$;

CREATE OR REPLACE PROCEDURE admin_management.delete_review(
    p_review_id BIGINT,
    p_admin_email VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    PERFORM admin_management.ensure_admin_email(p_admin_email);

    IF NOT EXISTS (SELECT 1 FROM reviews WHERE reviews.id = p_review_id) THEN
        RAISE EXCEPTION 'Review % not found', p_review_id;
    END IF;

    DELETE FROM reviews WHERE reviews.id = p_review_id;
END;
$$;
