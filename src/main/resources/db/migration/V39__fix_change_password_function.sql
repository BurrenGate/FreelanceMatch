-- V39: Fix change_password function to use password_hash column

-- Drop old function
DROP FUNCTION IF EXISTS account_management.change_password(VARCHAR, VARCHAR, VARCHAR);

-- Recreate function with correct column name
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
    -- Get account with correct column name
    SELECT id, password_hash INTO v_account_id, v_current_password
    FROM accounts
    WHERE email = p_email;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account not found';
    END IF;
    
    -- Verify old password
    IF v_current_password != p_old_password THEN
        RAISE EXCEPTION 'Current password is incorrect';
    END IF;
    
    -- Update password with correct column name
    UPDATE accounts
    SET password_hash = p_new_password,
        updated_at = NOW()
    WHERE id = v_account_id;
    
    RAISE NOTICE 'Password changed successfully for account %', v_account_id;
    
    RETURN 'PASSWORD_CHANGED';
END;
$$;

COMMENT ON FUNCTION account_management.change_password IS 'Change user password with old password verification (fixed)';
