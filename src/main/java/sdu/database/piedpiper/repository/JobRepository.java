package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.RecommendedJobDTO;
import sdu.database.piedpiper.model.FreelancerMatch;
import sdu.database.piedpiper.model.Job;

import java.sql.PreparedStatement;
import java.sql.Statement;
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

    public Job save(Job job) {
        String sql = "INSERT INTO jobs (client_id, title, description, budget_type, min_budget, max_budget, status_id) VALUES (?, ?, ?, ?, ?, ?, ?) RETURNING id";
        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbc.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, new String[]{"id"});
            ps.setLong(1, job.getClientId());
            ps.setString(2, job.getTitle());
            ps.setString(3, job.getDescription());
            ps.setString(4, job.getBudgetType());
            ps.setBigDecimal(5, job.getMinBudget());
            ps.setBigDecimal(6, job.getMaxBudget());
            ps.setInt(7, 1); // Assuming 1 is a default status like 'Open'
            return ps;
        }, keyHolder);

        Number key = keyHolder.getKey();
        if (key != null) {
            job.setId(key.longValue());
        }
        return job;
    }

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
                WHERE  js.status_name = 'OPEN'
                ORDER  BY j.created_at DESC
                """;
        log.debug("Executing findAll() jobs query - only OPEN jobs");
        return jdbc.query(sql, JOB_MAPPER);
    }

    public java.util.Optional<Job> findById(Long id) {
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
                WHERE  j.id = ?
                """;
        log.debug("Executing findById() for job {}", id);
        try {
            Job job = jdbc.queryForObject(sql, JOB_MAPPER, id);
            return java.util.Optional.ofNullable(job);
        } catch (Exception e) {
            log.warn("Job not found with id: {}", id);
            return java.util.Optional.empty();
        }
    }

    public Job update(Long id, Job job) {
        String sql = "UPDATE jobs SET title = ?, description = ?, budget_type = ?, min_budget = ?, max_budget = ? WHERE id = ?";
        int rowsAffected = jdbc.update(sql, 
                job.getTitle(), 
                job.getDescription(), 
                job.getBudgetType(), 
                job.getMinBudget(), 
                job.getMaxBudget(), 
                id);
        
        if (rowsAffected > 0) {
            job.setId(id);
            log.debug("Job {} updated successfully", id);
            return job;
        } else {
            throw new RuntimeException("Job not found with id: " + id);
        }
    }

    public void deleteById(Long id) {
        String sql = "CALL job_market.delete_job(?)";
        log.debug("Calling delete_job procedure for job {}", id);
        try {
            jdbc.update(sql, id);
            log.debug("Job {} deleted successfully", id);
        } catch (Exception e) {
            log.error("Error deleting job {}: {}", id, e.getMessage());
            throw new RuntimeException("Failed to delete job: " + e.getMessage());
        }
    }

    public List<FreelancerMatch> findRecommendedFreelancers(Long jobId) {
        log.debug("Calling get_recommended_freelancers for job {}", jobId);
        jdbc.execute("CALL job_market.get_recommended_freelancers(" + jobId + ")");

        String selectSql = """
                SELECT *,
                       job_market.get_freelancer_rating(profile_id) as rating,
                       job_market.get_freelancer_total_earnings(profile_id) as total_earnings,
                       job_market.get_active_jobs_count(profile_id) as active_jobs,
                       job_market.is_freelancer_available(profile_id) as is_available
                FROM temp_recommended_freelancers
                ORDER BY match_pct DESC, rating DESC
                """;
        return jdbc.query(selectSql, MATCH_MAPPER);
    }

    public Integer getActiveJobsCount(Long profileId) {
        log.debug("Calling get_active_jobs_count for profile {}", profileId);
        String sql = "SELECT job_market.get_active_jobs_count(?)";
        try {
            return jdbc.queryForObject(sql, Integer.class, profileId);
        } catch (Exception e) {
            log.warn("Error getting active jobs count for profile {}: {}", profileId, e.getMessage());
            return 0;
        }
    }

    public Integer getSkillMatchCount(Long jobId, Long profileId) {
        log.debug("Calling get_skill_match_count for job {} and profile {}", jobId, profileId);
        String sql = "SELECT job_market.get_skill_match_count(?, ?)";
        try {
            return jdbc.queryForObject(sql, Integer.class, jobId, profileId);
        } catch (Exception e) {
            log.warn("Error getting skill match count: {}", e.getMessage());
            return 0;
        }
    }


    public List<Job> findJobsByClientEmail(String email) {
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
                JOIN   profiles p ON p.id = j.client_id
                JOIN   accounts a ON a.id = p.account_id
                WHERE  a.email = ?
                ORDER  BY j.created_at DESC
                """;

        log.debug("Executing findJobsByClientEmail for user: {}", email);
        return jdbc.query(sql, JOB_MAPPER, email);
    }

    public List<RecommendedJobDTO> getRecommendedJobsForFreelancer(String email) {
        String sql = "SELECT * FROM job_management.get_recommended_jobs(?)";

        return jdbc.query(sql, (rs, rowNum) ->
                        RecommendedJobDTO.builder()
                                .id(rs.getLong("id"))
                                .clientId(rs.getLong("client_id"))
                                .title(rs.getString("title"))
                                .description(rs.getString("description"))
                                .budgetType(rs.getString("budget_type"))
                                .minBudget(rs.getBigDecimal("min_budget"))
                                .maxBudget(rs.getBigDecimal("max_budget"))
                                .statusName(rs.getString("status_name"))
                                .createdAt(rs.getTimestamp("created_at").toLocalDateTime())
                                .matchPercentage(rs.getDouble("match_percentage"))
                                .build()
                , email);
    }
}
