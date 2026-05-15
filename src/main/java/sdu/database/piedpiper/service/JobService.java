package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.response.JobDTO;
import sdu.database.piedpiper.dto.response.RecommendedJobDTO;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.exception.NotFoundException;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.FreelancerMatch;
import sdu.database.piedpiper.model.Job;
import sdu.database.piedpiper.model.JobRequiredSkill;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.JobRepository;
import sdu.database.piedpiper.repository.JobRequiredSkillRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.math.BigDecimal;
import java.util.List;

@Service
public class JobService {

    private static final Logger log = LoggerFactory.getLogger(JobService.class);

    private final JobRepository jobRepository;
    private final JobRequiredSkillRepository jobRequiredSkillRepository;
    private final AccountRepository accountRepository;
    private final ProfileRepository profileRepository;

    public JobService(JobRepository jobRepository, JobRequiredSkillRepository jobRequiredSkillRepository, AccountRepository accountRepository, ProfileRepository profileRepository) {
        this.jobRepository = jobRepository;
        this.jobRequiredSkillRepository = jobRequiredSkillRepository;
        this.accountRepository = accountRepository;
        this.profileRepository = profileRepository;
    }

    public List<Job> getAllJobs() {
        log.info("Fetching all jobs");
        return jobRepository.findAll();
    }

    public java.util.Optional<Job> getJobById(Long id) {
        log.info("Fetching job by id: {}", id);
        return jobRepository.findById(id);
    }

    public void updateJob(Long id, JobDTO jobDTO) {
        log.info("Updating job {}", id);
        java.util.Optional<Job> existingJob = jobRepository.findById(id);
        if (existingJob.isEmpty()) {
            throw new NotFoundException("Job not found with id: " + id);
        }

        Job job = existingJob.get();
        ensureCurrentClientOwnsJob(job);
        job.setTitle(jobDTO.getTitle());
        job.setDescription(jobDTO.getDescription());
        if (jobDTO.getBudget() != null) {
            BigDecimal budget = BigDecimal.valueOf(jobDTO.getBudget());
            job.setMinBudget(budget);
            job.setMaxBudget(budget);
        }

        jobRepository.update(id, job);

        // Update required skills if provided
        if (jobDTO.getRequiredSkillIds() != null && !jobDTO.getRequiredSkillIds().isEmpty()) {
            jobRequiredSkillRepository.deleteByJobId(id);
            for (Long skillId : jobDTO.getRequiredSkillIds()) {
                JobRequiredSkill jobRequiredSkill = new JobRequiredSkill();
                jobRequiredSkill.setJobId(id);
                jobRequiredSkill.setSkillId(skillId.intValue());
                jobRequiredSkillRepository.save(jobRequiredSkill);
            }
        }
    }

    public void deleteJob(Long id) {
        log.info("Deleting job {}", id);
        java.util.Optional<Job> existingJob = jobRepository.findById(id);
        if (existingJob.isEmpty()) {
            throw new NotFoundException("Job not found with id: " + id);
        }

        ensureCurrentClientOwnsJob(existingJob.get());

        jobRequiredSkillRepository.deleteByJobId(id);
        jobRepository.deleteById(id);
    }

    public List<FreelancerMatch> getRecommendedFreelancers(Long jobId) {
        log.info("Getting recommended freelancers for job {}", jobId);
        try {
            return jobRepository.findRecommendedFreelancers(jobId);
        } catch (DataAccessException e) {
            log.error("Error calling matching procedure for job {}: {}", jobId, e.getMessage());
            throw new RuntimeException("Matching procedure failed: " + extractMessage(e), e);
        }
    }

    public Integer getActiveJobsCount(Long profileId) {
        log.info("Getting active jobs count for profile {}", profileId);
        return jobRepository.getActiveJobsCount(profileId);
    }

    public Integer getSkillMatchCount(Long jobId, Long profileId) {
        log.info("Getting skill match count for job {} and freelancer {}", jobId, profileId);
        return jobRepository.getSkillMatchCount(jobId, profileId);
    }

    public void createJob(JobDTO jobDTO) {
        Profile profile = getCurrentProfile();

        Job job = new Job();
        job.setClientId(profile.getId());
        job.setTitle(jobDTO.getTitle());
        job.setDescription(jobDTO.getDescription());
        job.setBudgetType("fixed"); // Assuming fixed budget
        if (jobDTO.getBudget() != null) {
            BigDecimal budget = BigDecimal.valueOf(jobDTO.getBudget());
            job.setMinBudget(budget);
            job.setMaxBudget(budget);
        }
        Job savedJob = jobRepository.save(job);

        for (Long skillId : jobDTO.getRequiredSkillIds()) {
            JobRequiredSkill jobRequiredSkill = new JobRequiredSkill();
            jobRequiredSkill.setJobId(savedJob.getId());
            jobRequiredSkill.setSkillId(skillId.intValue());
            jobRequiredSkillRepository.save(jobRequiredSkill);
        }
    }

    public List<Job> getMyJobs() {
        String email = SecurityUtils.getCurrentUsername();

        if (email == null) {
            throw new RuntimeException("User is not authenticated");
        }

        // Передаем email напрямую в базу данных
        return jobRepository.findJobsByClientEmail(email);
    }

    public List<RecommendedJobDTO> getRecommendedJobs() {
        String email = SecurityUtils.getCurrentUsername();

        if (email == null) {
            throw new RuntimeException("User is not authenticated");
        }

        return jobRepository.getRecommendedJobsForFreelancer(email);
    }

    private String extractMessage(DataAccessException e) {
        Throwable cause = e.getMostSpecificCause();
        String msg = cause.getMessage();
        if (msg != null && msg.contains("ERROR:")) {
            int idx = msg.indexOf("ERROR:") + 6;
            return msg.substring(idx).split("\n")[0].trim();
        }
        return msg != null ? msg : "Unknown database error";
    }

    private Profile getCurrentProfile() {
        String username = SecurityUtils.getCurrentUsername();
        if (username == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        Account account = accountRepository.findByEmail(username);
        if (account == null) {
            throw new NotFoundException("Account not found for authenticated user");
        }
        return profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found for authenticated user"));
    }

    private void ensureCurrentClientOwnsJob(Job job) {
        Profile current = getCurrentProfile();
        if (!current.getId().equals(job.getClientId())) {
            throw new ForbiddenOperationException("You can only modify your own jobs");
        }
    }
}
