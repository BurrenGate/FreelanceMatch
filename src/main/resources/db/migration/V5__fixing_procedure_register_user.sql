-- 1. Sync counter for accounts table
SELECT setval(pg_get_serial_sequence('accounts', 'id'), COALESCE((SELECT MAX(id) FROM accounts), 1), max(id) IS NOT null) FROM accounts;

-- 2. Sync counter for profiles table
SELECT setval(pg_get_serial_sequence('profiles', 'id'), COALESCE((SELECT MAX(id) FROM profiles), 1), max(id) IS NOT null) FROM profiles;

CREATE OR REPLACE PROCEDURE register_user(
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
BEGIN
    INSERT INTO accounts (email, password_hash, role_id)
    VALUES (p_email, p_password_hash, p_role_id)
    RETURNING id INTO v_new_account_id;

    INSERT INTO profiles (account_id, first_name, last_name, hourly_rate)
    VALUES (v_new_account_id, p_first_name, p_last_name, p_hourly_rate);

    RAISE NOTICE 'User % successfully registered. Account ID: %', p_email, v_new_account_id;

EXCEPTION
    WHEN unique_violation THEN
        IF SQLERRM ILIKE '%email%' THEN
            RAISE EXCEPTION 'Account with email "%" already exists.', p_email;
        ELSE
            -- Otherwise output the real cause (e.g., Primary Key duplicate)
            RAISE EXCEPTION 'DB unique violation (possible ID out of sync): %', SQLERRM;
        END IF;

    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error during user registration %. Details: %', p_email, SQLERRM;
END;
$$;