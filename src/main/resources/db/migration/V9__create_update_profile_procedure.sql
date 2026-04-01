CREATE OR REPLACE PROCEDURE profile_management.update_profile(
    p_email         VARCHAR(255),
    p_first_name    VARCHAR(100),
    p_last_name     VARCHAR(100),
    p_bio           TEXT,
    p_hourly_rate   DECIMAL(10,2),
    p_avatar_url    VARCHAR(255)
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_account_id BIGINT;
BEGIN
    SELECT id INTO v_account_id FROM accounts WHERE email = p_email;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Account with email % not found', p_email;
    END IF;

    -- 2. Обновляем данные в таблице profiles
    -- (Предполагается, что пустая запись в profiles создается при регистрации)
    UPDATE profiles
    SET first_name  = p_first_name,
        last_name   = p_last_name,
        bio         = p_bio,
        hourly_rate = p_hourly_rate,
        avatar_url  = p_avatar_url,
        updated_at  = NOW()
    WHERE account_id = v_account_id;

    -- Если профиля еще не было (например, не создался при регистрации), создаем его
    IF NOT FOUND THEN
        INSERT INTO profiles (account_id, first_name, last_name, bio, hourly_rate, avatar_url)
        VALUES (v_account_id, p_first_name, p_last_name, p_bio, p_hourly_rate, p_avatar_url);
    END IF;

END;
$$;