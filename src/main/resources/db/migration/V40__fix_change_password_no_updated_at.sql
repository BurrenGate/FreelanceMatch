-- V40: Fix change_password function - remove updated_at column

DROP FUNCTION IF EXISTS account_management.change_password(VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION account_management.change_password(
    p_email VARCHAR(255),
    p_old_password VARCHAR(255),
    p_new_password VARCHAR(255)
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_account_id BIGINT;
    v_current_password VARCHAR(255);
BEGIN
    SELECT id, password_hash INTO v_account_id, v_current_password
    FROM accounts
    WHERE email = p_email;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account not found';
    END IF;
    
    IF v_current_password != p_old_password THEN
        RAISE EXCEPTION 'Current password is incorrect';
    END IF;
    
    UPDATE accounts
    SET password_hash = p_new_password
    WHERE id = v_account_id;
    
    RAISE NOTICE 'Password changed successfully for account %', v_account_id;
    
    RETURN 'PASSWORD_CHANGED';
END;
$$;

COMMENT ON FUNCTION account_management.change_password IS 'Change user password with old password verification';
