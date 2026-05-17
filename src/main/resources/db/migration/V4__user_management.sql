-- V4: This script sets up the user management schema and related procedures.

CREATE SCHEMA IF NOT EXISTS user_management;

-- Procedure to register a new user.
-- This procedure creates an account and a corresponding profile.
CREATE OR REPLACE PROCEDURE user_management.register_user(
    p_email         VARCHAR(255),
    p_password_hash VARCHAR(255),
    p_role_id       INTEGER,
    p_first_name    VARCHAR(100),
    p_last_name     VARCHAR(100),
    p_hourly_rate   DECIMAL(10,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_account_id BIGINT;
    v_role_exists    BOOLEAN;
BEGIN
    -- Check if the provided role_id is valid.
    SELECT EXISTS(SELECT 1 FROM roles WHERE id = p_role_id) INTO v_role_exists;
    IF NOT v_role_exists THEN
        RAISE EXCEPTION 'Invalid role_id: %', p_role_id;
    END IF;

    -- Insert the new account and get the generated ID.
    INSERT INTO accounts (email, password_hash, role_id)
    VALUES (p_email, p_password_hash, p_role_id)
    RETURNING id INTO v_new_account_id;

    -- Create a profile for the new account.
    INSERT INTO profiles (account_id, first_name, last_name, hourly_rate)
    VALUES (v_new_account_id, p_first_name, p_last_name, p_hourly_rate);

    RAISE NOTICE 'User % registered successfully. Account ID: %', p_email, v_new_account_id;

EXCEPTION
    WHEN unique_violation THEN
        -- Handle unique constraint violations, specifically for email.
        IF SQLERRM ILIKE '%accounts_email_key%' THEN
            RAISE EXCEPTION 'An account with the email "%" already exists.', p_email;
        ELSE
            -- Handle other unique violations, which might indicate a data sync issue.
            RAISE EXCEPTION 'A unique constraint was violated: %', SQLERRM;
        END IF;
    WHEN OTHERS THEN
        -- Catch any other errors and provide a generic error message.
        RAISE EXCEPTION 'An unexpected error occurred while registering user %: %', p_email, SQLERRM;
END;
$$;

COMMENT ON PROCEDURE user_management.register_user(VARCHAR, VARCHAR, INTEGER, VARCHAR, VARCHAR, DECIMAL)
IS 'Registers a new user by creating an account and a profile. It ensures the provided role is valid and handles potential duplicate email errors.';
