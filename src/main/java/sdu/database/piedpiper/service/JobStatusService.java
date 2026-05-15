package sdu.database.piedpiper.service;

import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.response.JobStatusManageResponse;
import sdu.database.piedpiper.dto.response.JobStatusResponse;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.repository.JobStatusRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;

@Service
public class JobStatusService {

    private final JobStatusRepository jobStatusRepository;

    public JobStatusService(JobStatusRepository jobStatusRepository) {
        this.jobStatusRepository = jobStatusRepository;
    }

    public JobStatusResponse getJobStatus(Long jobId) {
        return jobStatusRepository.getJobStatus(jobId, getCurrentUserEmail());
    }

    public JobStatusResponse updateJobStatus(Long jobId, String statusName) {
        String email = getCurrentUserEmail();
        jobStatusRepository.changeJobStatus(jobId, statusName, email);
        return jobStatusRepository.getJobStatus(jobId, email);
    }

    public List<JobStatusManageResponse> getManagedJobStatuses() {
        return jobStatusRepository.getManagedJobStatuses(getCurrentAdminEmail());
    }

    public JobStatusManageResponse createManagedJobStatus(String statusName) {
        return jobStatusRepository.createManagedJobStatus(statusName, getCurrentAdminEmail());
    }

    public JobStatusManageResponse updateManagedJobStatus(Integer statusId, String statusName) {
        return jobStatusRepository.updateManagedJobStatus(statusId, statusName, getCurrentAdminEmail());
    }

    public void deleteManagedJobStatus(Integer statusId) {
        jobStatusRepository.deleteManagedJobStatus(statusId, getCurrentAdminEmail());
    }

    private String getCurrentUserEmail() {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null || email.isBlank()) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        return email;
    }

    private String getCurrentAdminEmail() {
        if (!SecurityUtils.isAdmin()) {
            throw new ForbiddenOperationException("Only admins can manage job statuses");
        }
        return getCurrentUserEmail();
    }
}
