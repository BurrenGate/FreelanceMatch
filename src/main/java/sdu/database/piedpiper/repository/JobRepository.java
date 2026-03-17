package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.FreelancerMatch;
import sdu.database.piedpiper.model.Job;

import java.util.List;

@Repository
public class JobRepository {

    private static final Logger log = LoggerFactory.getLogger(JobRepository.class);

    private final JdbcTemplate jdbc;

    public JobRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

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
        fm.setRating(rs.getDouble("rating"));
        fm.setTotalEarnings(rs.getBigDecimal("total_earnings"));
        fm.setActiveJobs(rs.getInt("active_jobs"));
        fm.setIsAvailable(rs.getBoolean("is_available"));
        return fm;
    };

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

    public List<FreelancerMatch> findRecommendedFreelancers(Long jobId) {
        log.debug("Calling get_recommended_freelancers for job {}", jobId);
        jdbc.execute("CALL get_recommended_freelancers(" + jobId + ")");

        String selectSql = """
                SELECT *,
                       get_freelancer_rating(profile_id) as rating,
                       get_freelancer_total_earnings(profile_id) as total_earnings,
                       get_active_jobs_count(profile_id) as active_jobs,
                       is_freelancer_available(profile_id) as is_available
                FROM temp_recommended_freelancers
                ORDER BY match_pct DESC, rating DESC
                """;
        return jdbc.query(selectSql, MATCH_MAPPER);
    }

    public void finalizeProposalAndCreateContract(Long proposalId) {
        log.debug("Calling finalize_proposal_and_create_contract for proposal {}", proposalId);
        jdbc.execute("CALL finalize_proposal_and_create_contract(" + proposalId + ")");
    }
}

