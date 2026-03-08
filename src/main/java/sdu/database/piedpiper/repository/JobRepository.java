package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.FreelancerMatch;
import sdu.database.piedpiper.model.Job;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

/**
 * Data-access layer.
 * Uses JdbcTemplate to:
 *  1. Query the jobs table (plain SQL).
 *  2. Call the stored procedures via CALL / SELECT.
 *
 * NOTE: We use JdbcTemplate intentionally (not JPA) because this
 * project is about demonstrating raw SQL / stored procedure calls.
 */
@Repository
public class JobRepository {

    private static final Logger log = LoggerFactory.getLogger(JobRepository.class);

    // Spring auto-injects the JdbcTemplate configured in application.properties
    private final JdbcTemplate jdbc;

    public JobRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // ─── RowMappers ───────────────────────────────────────────

    /** Maps one row from the jobs query to a Job object */
    private static final RowMapper<Job> JOB_MAPPER = (rs, rowNum) -> {
        Job j = new Job();
        j.setId(rs.getLong("id"));
        j.setClientId(rs.getLong("client_id"));
        j.setTitle(rs.getString("title"));
        j.setDescription(rs.getString("description"));
        j.setBudgetType(rs.getString("budget_type"));
        j.setMinBudget(rs.getBigDecimal("min_budget"));
        j.setMaxBudget(rs.getBigDecimal("max_budget"));
        j.setStatusName(rs.getString("status_name"));
        j.setCreatedAt(rs.getTimestamp("created_at") != null
                ? rs.getTimestamp("created_at").toLocalDateTime()
                : null);
        return j;
    };

    /** Maps one row from temp_recommended_freelancers to a FreelancerMatch object */
    private static final RowMapper<FreelancerMatch> MATCH_MAPPER = (rs, rowNum) -> {
        FreelancerMatch fm = new FreelancerMatch();
        fm.setProfileId(rs.getLong("profile_id"));
        fm.setFullName(rs.getString("full_name"));
        fm.setHourlyRate(rs.getBigDecimal("hourly_rate"));
        fm.setEmail(rs.getString("email"));
        fm.setMatchPct(rs.getDouble("match_pct"));
        return fm;
    };

    // ─── Public methods ───────────────────────────────────────

    /**
     * Returns all jobs joined with their status names.
     * Called by GET /api/jobs.
     */
    public List<Job> findAll() {
        String sql = """
                SELECT j.id,
                       j.client_id,
                       j.title,
                       j.description,
                       j.budget_type,
                       j.min_budget,
                       j.max_budget,
                       j.created_at,
                       js.status_name
                FROM   jobs j
                JOIN   job_statuses js ON js.id = j.status_id
                ORDER  BY j.created_at DESC
                """;
        log.debug("Executing findAll() jobs query");
        return jdbc.query(sql, JOB_MAPPER);
    }

    /**
     * Calls the CURSOR-based stored procedure to find recommended freelancers.
     *
     * Flow:
     *  1.  CALL get_recommended_freelancers(jobId)
     *      → procedure populates the session-scoped temp table.
     *  2.  SELECT * FROM temp_recommended_freelancers
     *      → retrieve the results.
     *
     * Called by GET /api/jobs/{id}/match.
     */
    public List<FreelancerMatch> findRecommendedFreelancers(Long jobId) {
        // Step 1 – invoke the procedure (REQUIREMENT A: Cursors & Loops)
        log.debug("Calling get_recommended_freelancers for job {}", jobId);
        jdbc.execute("CALL get_recommended_freelancers(" + jobId + ")");

        // Step 2 – read results from the temp table the procedure created
        String selectSql = "SELECT * FROM temp_recommended_freelancers ORDER BY match_pct DESC";
        return jdbc.query(selectSql, MATCH_MAPPER);
    }

    /**
     * Calls the NESTED BLOCK procedure to accept a proposal and create a contract.
     *
     * The procedure itself enforces:
     *   - proposal must be 'pending'
     *   - job must be 'OPEN'
     *   - rolls back automatically if any DML step fails
     *
     * We catch any exception thrown by the DB and re-throw as a
     * RuntimeException so the service layer can translate it to an
     * HTTP error response.
     *
     * Called by POST /api/proposals/{id}/accept.
     */
    public void finalizeProposalAndCreateContract(Long proposalId) {
        log.debug("Calling finalize_proposal_and_create_contract for proposal {}", proposalId);
        // Step 1 – invoke the procedure (REQUIREMENT B: Conditionals & Nested Blocks)
        jdbc.execute("CALL finalize_proposal_and_create_contract(" + proposalId + ")");
    }
}

