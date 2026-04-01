CREATE OR REPLACE FUNCTION get_freelancer_dashboard(p_freelancer_id BIGINT)
    RETURNS JSONB AS $$
DECLARE
    v_total_earnings DECIMAL(15,2);
    v_active_contracts INTEGER;
    v_completed_jobs INTEGER;
    v_pending_proposals INTEGER;
    v_total_proposals INTEGER;
    v_avg_rating NUMERIC;
    v_job_success_score NUMERIC;
    v_recent_activity JSONB;
    v_result JSONB;
BEGIN
    -- 1. Считаем общий заработок
    SELECT COALESCE(SUM(t.amount), 0) INTO v_total_earnings
    FROM transactions t
             JOIN contracts c ON t.contract_id = c.id
    WHERE c.freelancer_id = p_freelancer_id AND t.type = 'payment';

    -- 2. Статистика по контрактам
    SELECT
        COUNT(CASE WHEN status = 'active' THEN 1 END),
        COUNT(CASE WHEN status = 'completed' THEN 1 END)
    INTO v_active_contracts, v_completed_jobs
    FROM contracts
    WHERE freelancer_id = p_freelancer_id;

    -- 3. Статистика по откликам (proposals)
    SELECT
        COUNT(CASE WHEN status = 'pending' THEN 1 END),
        COUNT(*)
    INTO v_pending_proposals, v_total_proposals
    FROM proposals
    WHERE freelancer_id = p_freelancer_id;

    -- 4. Рейтинг и Job Success Score (JSS)
    SELECT COALESCE(AVG(r.rating), 0) INTO v_avg_rating
    FROM reviews r
             JOIN contracts c ON r.contract_id = c.id
    WHERE c.freelancer_id = p_freelancer_id AND r.reviewer_id != p_freelancer_id;

    v_job_success_score := (v_avg_rating / 5.0) * 100;

    -- 5. Последняя активность (Объединяем proposals и transactions)
    -- Обратите внимание на двойные кавычки в алиасах (AS "activityType") - это важно для маппинга JSON в Java (camelCase)
    WITH activity AS (
        SELECT
            'PROPOSAL' AS "activityType",
            j.title AS "title",
            p.status AS "status",
            p.bid_amount AS "amount",
            p.created_at AS "date"
        FROM proposals p
                 JOIN jobs j ON p.job_id = j.id
        WHERE p.freelancer_id = p_freelancer_id

        UNION ALL

        SELECT
            'TRANSACTION' AS "activityType",
            j.title AS "title",
            t.type AS "status",
            t.amount AS "amount",
            t.created_at AS "date"
        FROM transactions t
                 JOIN contracts c ON t.contract_id = c.id
                 JOIN jobs j ON c.job_id = j.id
        WHERE c.freelancer_id = p_freelancer_id

        ORDER BY "date" DESC
        LIMIT 10
    )
    SELECT COALESCE(jsonb_agg(row_to_json(activity)), '[]'::jsonb) INTO v_recent_activity FROM activity;

    -- 6. Формируем итоговый JSON-объект
    v_result := jsonb_build_object(
            'totalEarnings', v_total_earnings,
            'activeContracts', COALESCE(v_active_contracts, 0),
            'completedJobs', COALESCE(v_completed_jobs, 0),
            'pendingProposals', COALESCE(v_pending_proposals, 0),
            'totalProposalsSubmitted', COALESCE(v_total_proposals, 0),
            'averageRating', ROUND(v_avg_rating, 1),
            'jobSuccessScore', ROUND(v_job_success_score, 0),
            'recentActivity', v_recent_activity
                );

    RETURN v_result;
END;
$$ LANGUAGE plpgsql;