package sdu.database.piedpiper.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.JobStatusManageResponse;
import sdu.database.piedpiper.dto.response.JobStatusResponse;

import java.util.List;

@Repository
public class JobStatusRepository {

    private final JdbcTemplate jdbcTemplate;

    public JobStatusRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void changeJobStatus(Long jobId, String statusName, String clientEmail) {
        String sql = "CALL job_management.change_job_status(?, ?, ?)";
        jdbcTemplate.update(sql, jobId, statusName, clientEmail);
    }

    public JobStatusResponse getJobStatus(Long jobId, String clientEmail) {
        String sql = "SELECT * FROM job_management.get_job_status(?, ?)";
        return jdbcTemplate.queryForObject(
                sql,
                (rs, rowNum) -> JobStatusResponse.builder()
                        .jobId(rs.getLong("job_id"))
                        .statusId(rs.getInt("status_id"))
                        .statusName(rs.getString("status_name"))
                        .build(),
                jobId,
                clientEmail
        );
    }

    public List<JobStatusManageResponse> getManagedJobStatuses(String adminEmail) {
        String sql = "SELECT * FROM admin_management.get_job_statuses(?)";
        return jdbcTemplate.query(
                sql,
                (rs, rowNum) -> JobStatusManageResponse.builder()
                        .id(rs.getInt("id"))
                        .statusName(rs.getString("status_name"))
                        .build(),
                adminEmail
        );
    }

    public JobStatusManageResponse createManagedJobStatus(String statusName, String adminEmail) {
        String sql = "SELECT * FROM admin_management.create_job_status(?, ?)";
        return jdbcTemplate.queryForObject(
                sql,
                (rs, rowNum) -> JobStatusManageResponse.builder()
                        .id(rs.getInt("id"))
                        .statusName(rs.getString("status_name"))
                        .build(),
                statusName,
                adminEmail
        );
    }

    public JobStatusManageResponse updateManagedJobStatus(Integer statusId, String statusName, String adminEmail) {
        String sql = "SELECT * FROM admin_management.update_job_status(?, ?, ?)";
        return jdbcTemplate.queryForObject(
                sql,
                (rs, rowNum) -> JobStatusManageResponse.builder()
                        .id(rs.getInt("id"))
                        .statusName(rs.getString("status_name"))
                        .build(),
                statusId,
                statusName,
                adminEmail
        );
    }

    public void deleteManagedJobStatus(Integer statusId, String adminEmail) {
        String sql = "CALL admin_management.delete_job_status(?, ?)";
        jdbcTemplate.update(sql, statusId, adminEmail);
    }
}
