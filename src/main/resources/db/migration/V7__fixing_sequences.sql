DO $$
    DECLARE
        rec RECORD;
        seq_name TEXT;
    BEGIN
        -- Проходим ТОЛЬКО по таблицам, у которых есть колонка 'id'
        FOR rec IN (
            SELECT table_name AS tablename
            FROM information_schema.columns
            WHERE table_schema = 'public'
              AND column_name = 'id'
        ) LOOP
                -- Пытаемся получить имя sequence для колонки 'id'
                seq_name := pg_get_serial_sequence('"' || rec.tablename || '"', 'id');

                -- Если sequence существует, обновляем его
                IF seq_name IS NOT NULL THEN
                    EXECUTE format(
                            'SELECT setval(''%s'', COALESCE((SELECT MAX(id) FROM %I), 1), (SELECT MAX(id) IS NOT NULL FROM %I));',
                            seq_name, rec.tablename, rec.tablename
                            );
                    RAISE NOTICE 'Синхронизирован счетчик % для таблицы %', seq_name, rec.tablename;
                END IF;
            END LOOP;
    END $$;


CREATE OR REPLACE PROCEDURE finalize_proposal_and_create_contract(p_proposal_id BIGINT)
    LANGUAGE plpgsql
AS $$
DECLARE
    v_proposal_status  VARCHAR(50);
    v_job_id           BIGINT;
    v_job_status_id    INTEGER;
    v_job_status_name  VARCHAR(50);
    v_freelancer_id    BIGINT;
    v_bid_amount       DECIMAL(15,2);
    v_new_contract_id  BIGINT;
BEGIN
    -- 1. Читаем данные и блокируем строку (FOR UPDATE)
    SELECT status, job_id, freelancer_id, bid_amount
    INTO   v_proposal_status, v_job_id, v_freelancer_id, v_bid_amount
    FROM   proposals
    WHERE  id = p_proposal_id
        FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Proposal % does not exist.', p_proposal_id;
    END IF;

    IF v_proposal_status <> 'pending' THEN
        RAISE EXCEPTION
            'Proposal % cannot be accepted – current status is "%".',
            p_proposal_id, v_proposal_status;
    END IF;

    -- 2. Читаем статус работы и также блокируем её (FOR UPDATE OF j)
    SELECT j.status_id, js.status_name
    INTO   v_job_status_id, v_job_status_name
    FROM   jobs j
               JOIN   job_statuses js ON js.id = j.status_id
    WHERE  j.id = v_job_id
        FOR UPDATE OF j;

    IF v_job_status_name <> 'OPEN' THEN
        RAISE EXCEPTION
            'Job % cannot be contracted – current status is "%".',
            v_job_id, v_job_status_name;
    END IF;

    -- 3. Выполняем обновления и вставку
    BEGIN
        UPDATE proposals
        SET    status = 'accepted'
        WHERE  id = p_proposal_id;

        UPDATE jobs
        SET    status_id = 2
        WHERE  id = v_job_id;

        INSERT INTO contracts (job_id, freelancer_id, total_amount, status)
        VALUES (v_job_id, v_freelancer_id, v_bid_amount, 'active')
        RETURNING id INTO v_new_contract_id;

        RAISE NOTICE 'Contract % created for job % with freelancer %.',
            v_new_contract_id, v_job_id, v_freelancer_id;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION
                'Contract creation failed (proposal %). Rolling back. Detail: %',
                p_proposal_id, SQLERRM;
    END;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;