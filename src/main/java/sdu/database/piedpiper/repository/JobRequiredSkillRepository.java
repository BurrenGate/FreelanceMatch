package sdu.database.piedpiper.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.JobRequiredSkillResponse;
import sdu.database.piedpiper.model.JobRequiredSkill;

import java.util.List;

@Repository
public class JobRequiredSkillRepository {

    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public JobRequiredSkillRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<JobRequiredSkill> findByJobId(Long jobId) {
        String sql = "SELECT job_id, skill_id FROM job_required_skills WHERE job_id = ?";
        return jdbcTemplate.query(
                sql,
                new Object[]{jobId},
                (rs, rowNum) -> new JobRequiredSkill(
                        rs.getLong("job_id"),
                        rs.getInt("skill_id")
                )
        );
    }

    public JobRequiredSkill save(JobRequiredSkill jobRequiredSkill) {
        String sql = "INSERT INTO job_required_skills (job_id, skill_id) VALUES (?, ?)";
        jdbcTemplate.update(
                sql,
                jobRequiredSkill.getJobId(),
                jobRequiredSkill.getSkillId()
        );
        return jobRequiredSkill;
    }

    public void deleteByJobId(Long jobId) {
        String sql = "DELETE FROM job_required_skills WHERE job_id = ?";
        jdbcTemplate.update(sql, jobId);
    }

    public void addJobRequiredSkill(Long jobId, Integer skillId, String clientEmail) {
        String sql = "CALL job_management.add_job_required_skill(?, ?, ?)";
        jdbcTemplate.update(sql, jobId, skillId, clientEmail);
    }

    public void removeJobRequiredSkill(Long jobId, Integer skillId, String clientEmail) {
        String sql = "CALL job_management.remove_job_required_skill(?, ?, ?)";
        jdbcTemplate.update(sql, jobId, skillId, clientEmail);
    }

    public List<JobRequiredSkillResponse> getJobRequiredSkills(Long jobId, String clientEmail) {
        String sql = "SELECT * FROM job_management.get_job_required_skills(?, ?)";
        return jdbcTemplate.query(
                sql,
                (rs, rowNum) -> JobRequiredSkillResponse.builder()
                        .skillId(rs.getInt("skill_id"))
                        .skillName(rs.getString("skill_name"))
                        .category(rs.getString("category"))
                        .build(),
                jobId,
                clientEmail
        );
    }
}
