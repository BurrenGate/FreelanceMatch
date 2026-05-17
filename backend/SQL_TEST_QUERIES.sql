-- SQL запросы для тестирования новых функций
-- Выполнять в PostgreSQL: docker exec -it freelancematch-db-1 psql -U user -d freelance

-- ============================================================================
-- 1. Проверка применения миграций
-- ============================================================================

SELECT version, description, installed_on 
FROM flyway_schema_history 
WHERE version IN ('27', '28', '29')
ORDER BY installed_rank;

-- ============================================================================
-- 2. Проверка созданных функций и процедур
-- ============================================================================

-- Список всех функций в схеме job_market
\df job_market.*

-- Или через SQL
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'job_market'
  AND routine_name IN (
    'reject_proposal',
    'get_freelancer_profile',
    'get_freelancer_skills',
    'get_freelancer_reviews',
    'get_proposals_with_freelancer_details',
    'finalize_proposal_and_create_contract'
  )
ORDER BY routine_name;

-- ============================================================================
-- 3. Тестирование функции get_freelancer_profile
-- ============================================================================

-- Найти ID фрилансера
SELECT p.id, p.first_name, p.last_name, a.email, a.role_id
FROM profiles p
JOIN accounts a ON a.id = p.account_id
WHERE a.role_id = 2  -- freelancer
LIMIT 5;

-- Получить профиль фрилансера (замените 2 на реальный ID)
SELECT * FROM job_market.get_freelancer_profile(2);

-- ============================================================================
-- 4. Тестирование функции get_freelancer_skills
-- ============================================================================

-- Получить навыки фрилансера (замените 2 на реальный ID)
SELECT * FROM job_market.get_freelancer_skills(2);

-- ============================================================================
-- 5. Тестирование функции get_freelancer_reviews
-- ============================================================================

-- Получить отзывы фрилансера (замените 2 на реальный ID)
SELECT * FROM job_market.get_freelancer_reviews(2, 10);

-- ============================================================================
-- 6. Тестирование функции get_proposals_with_freelancer_details
-- ============================================================================

-- Найти ID заказа с предложениями
SELECT j.id, j.title, COUNT(pr.id) as proposal_count
FROM jobs j
LEFT JOIN proposals pr ON pr.job_id = j.id
GROUP BY j.id, j.title
HAVING COUNT(pr.id) > 0
LIMIT 5;

-- Получить предложения с данными фрилансеров (замените 1 на реальный job_id)
SELECT * FROM job_market.get_proposals_with_freelancer_details(1);

-- ============================================================================
-- 7. Тестирование процедуры reject_proposal
-- ============================================================================

-- Найти pending предложение
SELECT id, job_id, freelancer_id, status, bid_amount
FROM proposals
WHERE status = 'pending'
LIMIT 5;

-- Отклонить предложение (замените 67 на реальный ID)
CALL job_market.reject_proposal(67);

-- Проверить, что статус изменился
SELECT id, job_id, freelancer_id, status
FROM proposals
WHERE id = 67;

-- ============================================================================
-- 8. Тестирование процедуры finalize_proposal_and_create_contract
-- ============================================================================

-- Найти pending предложение для теста
SELECT pr.id, pr.job_id, pr.freelancer_id, pr.status, pr.bid_amount,
       j.title, j.status_id
FROM proposals pr
JOIN jobs j ON j.id = pr.job_id
WHERE pr.status = 'pending'
LIMIT 5;

-- Принять предложение (замените 68 на реальный ID)
CALL job_market.finalize_proposal_and_create_contract(68);

-- Проверить результаты:

-- 1. Предложение должно быть accepted
SELECT id, job_id, status FROM proposals WHERE id = 68;

-- 2. Другие предложения для этого job должны быть rejected
SELECT id, job_id, status FROM proposals WHERE job_id = (SELECT job_id FROM proposals WHERE id = 68);

-- 3. Должен быть создан контракт
SELECT * FROM contracts WHERE job_id = (SELECT job_id FROM proposals WHERE id = 68);

-- 4. Статус заказа должен быть IN_PROGRESS (status_id = 2)
SELECT id, title, status_id FROM jobs WHERE id = (SELECT job_id FROM proposals WHERE id = 68);

-- ============================================================================
-- 9. Проверка колонки created_at в contracts
-- ============================================================================

SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'contracts'
  AND column_name = 'created_at';

-- Проверить данные
SELECT id, job_id, freelancer_id, status, created_at
FROM contracts
ORDER BY created_at DESC
LIMIT 10;

-- ============================================================================
-- 10. Полный тест workflow
-- ============================================================================

-- Шаг 1: Создать тестовый заказ (если нужно)
-- Сначала найти client_id
SELECT p.id, p.first_name, p.last_name, a.email
FROM profiles p
JOIN accounts a ON a.id = p.account_id
WHERE a.role_id = 1  -- client
LIMIT 1;

-- Шаг 2: Найти freelancer_id
SELECT p.id, p.first_name, p.last_name, a.email
FROM profiles p
JOIN accounts a ON a.id = p.account_id
WHERE a.role_id = 2  -- freelancer
LIMIT 1;

-- Шаг 3: Создать предложение вручную для теста
INSERT INTO proposals (job_id, freelancer_id, bid_amount, cover_letter, status)
VALUES (1, 2, 500.00, 'Test proposal', 'pending')
RETURNING id;

-- Шаг 4: Получить предложения с данными фрилансеров
SELECT * FROM job_market.get_proposals_with_freelancer_details(1);

-- Шаг 5: Просмотреть профиль фрилансера
SELECT * FROM job_market.get_freelancer_profile(2);

-- Шаг 6: Принять или отклонить предложение
-- CALL job_market.finalize_proposal_and_create_contract(PROPOSAL_ID);
-- или
-- CALL job_market.reject_proposal(PROPOSAL_ID);

-- ============================================================================
-- 11. Очистка тестовых данных (если нужно)
-- ============================================================================

-- Удалить тестовые контракты
-- DELETE FROM contracts WHERE id = YOUR_TEST_CONTRACT_ID;

-- Удалить тестовые предложения
-- DELETE FROM proposals WHERE id = YOUR_TEST_PROPOSAL_ID;

-- Вернуть статус предложения в pending
-- UPDATE proposals SET status = 'pending' WHERE id = YOUR_PROPOSAL_ID;

-- Вернуть статус заказа в OPEN
-- UPDATE jobs SET status_id = 1 WHERE id = YOUR_JOB_ID;

-- ============================================================================
-- 12. Полезные запросы для отладки
-- ============================================================================

-- Статистика по предложениям
SELECT status, COUNT(*) as count
FROM proposals
GROUP BY status;

-- Статистика по контрактам
SELECT status, COUNT(*) as count
FROM contracts
GROUP BY status;

-- Статистика по заказам
SELECT js.status_name, COUNT(*) as count
FROM jobs j
JOIN job_statuses js ON js.id = j.status_id
GROUP BY js.status_name;

-- Фрилансеры с наибольшим количеством завершенных работ
SELECT 
    p.id,
    CONCAT(p.first_name, ' ', p.last_name) as name,
    COUNT(c.id) as completed_jobs,
    job_market.get_freelancer_rating(p.id) as rating,
    job_market.get_freelancer_total_earnings(p.id) as total_earnings
FROM profiles p
LEFT JOIN contracts c ON c.freelancer_id = p.id AND c.status = 'completed'
JOIN accounts a ON a.id = p.account_id
WHERE a.role_id = 2
GROUP BY p.id, p.first_name, p.last_name
ORDER BY completed_jobs DESC
LIMIT 10;
