package sdu.database.piedpiper.service;

import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.response.JobRequiredSkillResponse;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.repository.JobRequiredSkillRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;

@Service
public class JobRequiredSkillService {

    private final JobRequiredSkillRepository jobRequiredSkillRepository;

    public JobRequiredSkillService(JobRequiredSkillRepository jobRequiredSkillRepository) {
        this.jobRequiredSkillRepository = jobRequiredSkillRepository;
    }

    public List<JobRequiredSkillResponse> getRequiredSkills(Long jobId) {
        String email = getCurrentUserEmail();
        return jobRequiredSkillRepository.getJobRequiredSkills(jobId, email);
    }

    public void addRequiredSkill(Long jobId, Integer skillId) {
        String email = getCurrentUserEmail();
        jobRequiredSkillRepository.addJobRequiredSkill(jobId, skillId, email);
    }

    public void removeRequiredSkill(Long jobId, Integer skillId) {
        String email = getCurrentUserEmail();
        jobRequiredSkillRepository.removeJobRequiredSkill(jobId, skillId, email);
    }

    private String getCurrentUserEmail() {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null || email.isBlank()) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        return email;
    }
}
