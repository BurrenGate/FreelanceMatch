-- V30: Safe job deletion with cascade handling

-- Procedure to safely delete a job with all related data
CREATE OR REPLACE PROCEDURE job_market.delete_job(
    p_job_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_job_exists BOOLEAN;
BEGIN
    -- Check if job exists
    SELECT EXISTS(SELECT 1 FROM jobs WHERE id = p_job_id) INTO v_job_exists;
    
    IF NOT v_job_exists THEN
        RAISE EXCEPTION 'Job with ID % does not exist', p_job_id;
    END IF;
    
    -- Delete reviews related to contracts of this job
    DELETE FROM reviews 
    WHERE contract_id IN (SELECT id FROM contracts WHERE job_id = p_job_id);
    
    -- Delete transactions related to contracts of this job
    DELETE FROM transactions 
    WHERE contract_id IN (SELECT id FROM contracts WHERE job_id = p_job_id);
    
    -- Delete contracts for this job
    DELETE FROM contracts WHERE job_id = p_job_id;
    
    -- Delete proposals for this job (CASCADE should handle this, but explicit is safer)
    DELETE FROM proposals WHERE job_id = p_job_id;
    
    -- Delete job required skills (CASCADE should handle this)
    DELETE FROM job_required_skills WHERE job_id = p_job_id;
    
    -- Finally, delete the job itself
    DELETE FROM jobs WHERE id = p_job_id;
    
    RAISE NOTICE 'Job % and all related data deleted successfully', p_job_id;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error deleting job %: %', p_job_id, SQLERRM;
END;
$$;

COMMENT ON PROCEDURE job_market.delete_job IS 'Safely deletes a job with all related data (contracts, proposals, reviews, transactions)';
