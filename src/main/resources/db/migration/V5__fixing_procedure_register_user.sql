-- Синхронизируем счетчик для таблицы accounts
SELECT setval(pg_get_serial_sequence('accounts', 'id'), COALESCE((SELECT MAX(id) FROM accounts), 1), max(id) IS NOT null) FROM accounts;

-- На всякий случай сделаем то же самое для профилей
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
    -- 1. Создаем аккаунт и захватываем сгенерированный ID
    INSERT INTO accounts (email, password_hash, role_id)
    VALUES (p_email, p_password_hash, p_role_id)
    RETURNING id INTO v_new_account_id;

    -- 2. Создаем профиль, привязывая его к новому аккаунту
    INSERT INTO profiles (account_id, first_name, last_name, hourly_rate)
    VALUES (v_new_account_id, p_first_name, p_last_name, p_hourly_rate);

    RAISE NOTICE 'Пользователь % успешно зарегистрирован. ID аккаунта: %', p_email, v_new_account_id;

EXCEPTION
    WHEN unique_violation THEN
        -- Проверяем текст ошибки: если там упоминается email, значит проблема действительно в нем
        IF SQLERRM ILIKE '%email%' THEN
            RAISE EXCEPTION 'Аккаунт с email "%" уже существует.', p_email;
        ELSE
            -- Иначе выводим реальную причину (например, дубликат Primary Key)
            RAISE EXCEPTION 'Нарушение уникальности БД (возможно рассинхрон ID): %', SQLERRM;
        END IF;

    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ошибка при регистрации пользователя %. Детали: %', p_email, SQLERRM;
END;
$$;