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

    -- Логируем успешное создание (будет видно в консоли PostgreSQL)
    RAISE NOTICE 'Пользователь % успешно зарегистрирован. ID аккаунта: %', p_email, v_new_account_id;

EXCEPTION
    -- Перехватываем ошибку дубликата email (UNIQUE constraint на accounts.email)
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Аккаунт с email "%" уже существует.', p_email;

    -- Перехватываем любые другие ошибки и откатываем транзакцию
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ошибка при регистрации пользователя %. Детали: %', p_email, SQLERRM;
END;
$$;


CREATE OR REPLACE PROCEDURE submit_proposal(
    p_job_id        BIGINT,
    p_freelancer_id BIGINT,
    p_bid_amount    DECIMAL(15,2),
    p_cover_letter  TEXT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_job_status_id INTEGER;
BEGIN
    -- 1. Проверяем статус задачи (нас интересует только OPEN, id = 1)
    SELECT status_id INTO v_job_status_id
    FROM jobs
    WHERE id = p_job_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Задача с ID % не найдена.', p_job_id;
    END IF;

    IF v_job_status_id <> 1 THEN
        RAISE EXCEPTION 'Невозможно подать заявку. Задача больше не открыта (текущий статус_id: %).', v_job_status_id;
    END IF;

    -- 2. Защита от двойного отклика (бизнес-логика на уровне БД)
    IF EXISTS (SELECT 1 FROM proposals WHERE job_id = p_job_id AND freelancer_id = p_freelancer_id) THEN
        RAISE EXCEPTION 'Фрилансер % уже подал заявку на задачу %.', p_freelancer_id, p_job_id;
    END IF;

    -- 3. Создаем заявку
    INSERT INTO proposals (job_id, freelancer_id, bid_amount, cover_letter, status)
    VALUES (p_job_id, p_freelancer_id, p_bid_amount, p_cover_letter, 'pending');

    RAISE NOTICE 'Заявка от фрилансера % на задачу % успешно подана.', p_freelancer_id, p_job_id;
END;
$$;


CREATE OR REPLACE PROCEDURE complete_job_and_rate(
    p_contract_id BIGINT,
    p_rating      NUMERIC, -- Принимаем NUMERIC, так как из Java летит BigDecimal
    p_feedback    TEXT
)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_contract_status VARCHAR(50);
    v_job_id          BIGINT;
    v_freelancer_id   BIGINT;
    v_total_amount    DECIMAL(15,2);
    v_client_id       BIGINT;
    v_int_rating      INTEGER;
BEGIN
    -- Приводим рейтинг к целому числу и валидируем (ограничение БД: 1-5)
    v_int_rating := ROUND(p_rating);

    IF v_int_rating < 1 OR v_int_rating > 5 THEN
        RAISE EXCEPTION 'Рейтинг должен быть от 1 до 5, получено: %', v_int_rating;
    END IF;

    -- 1. Получаем данные по контракту
    SELECT status, job_id, freelancer_id, total_amount
    INTO v_contract_status, v_job_id, v_freelancer_id, v_total_amount
    FROM contracts
    WHERE id = p_contract_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Контракт % не найден.', p_contract_id;
    END IF;

    IF v_contract_status <> 'active' THEN
        RAISE EXCEPTION 'Контракт % не активен (текущий статус: %). Завершение невозможно.', p_contract_id, v_contract_status;
    END IF;

    -- Получаем ID заказчика из таблицы jobs (он будет числиться автором отзыва)
    SELECT client_id INTO v_client_id FROM jobs WHERE id = v_job_id;

    -- 2. Закрываем контракт
    UPDATE contracts SET status = 'completed' WHERE id = p_contract_id;

    -- 3. Переводим задачу в статус COMPLETED (id = 3)
    UPDATE jobs SET status_id = 3 WHERE id = v_job_id;

    -- 4. Проводим транзакцию (оплата)
    INSERT INTO transactions (contract_id, amount, type)
    VALUES (p_contract_id, v_total_amount, 'payment');

    -- 5. Оставляем отзыв
    INSERT INTO reviews (contract_id, reviewer_id, rating, comment)
    VALUES (p_contract_id, v_client_id, v_int_rating, p_feedback);

    RAISE NOTICE 'Контракт % успешно завершен. Транзакция на сумму % проведена. Оценка: %',
        p_contract_id, v_total_amount, v_int_rating;

EXCEPTION
    -- Если хотя бы один этап упадет, откатится всё (атомарность!)
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Ошибка при завершении контракта %. Детали: %', p_contract_id, SQLERRM;
END;
$$;
