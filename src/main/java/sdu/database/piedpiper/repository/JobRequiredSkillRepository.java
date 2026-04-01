package sdu.database.piedpiper.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
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
}
