-- V37: Update last login timestamp

-- Function to update last login
CREATE OR REPLACE FUNCTION account_management.update_last_login(
    p_email VARCHAR(255)
)
RETURNS TIMESTAMP
LANGUAGE plpgsql
AS $$
DECLARE
    v_last_login TIMESTAMP;
BEGIN
    UPDATE accounts
    SET last_login = NOW()
    WHERE email = p_email
    RETURNING last_login INTO v_last_login;
    
    RETURN v_last_login;
END;
$$;

COMMENT ON FUNCTION account_management.update_last_login IS 'Update last login timestamp for user';
