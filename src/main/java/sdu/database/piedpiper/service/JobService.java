package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.response.JobDTO;
import sdu.database.piedpiper.dto.response.RecommendedJobDTO;
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

    public List<FreelancerMatch> getRecommendedFreelancers(Long jobId) {
        log.info("Getting recommended freelancers for job {}", jobId);
        try {
            return jobRepository.findRecommendedFreelancers(jobId);
        } catch (DataAccessException e) {
            log.error("Error calling matching procedure for job {}: {}", jobId, e.getMessage());
            throw new RuntimeException("Matching procedure failed: " + extractMessage(e), e);
        }
    }

    public void acceptProposal(Long proposalId) {
        log.info("Accepting proposal {}", proposalId);
        try {
            jobRepository.finalizeProposalAndCreateContract(proposalId);
        } catch (DataAccessException e) {
            log.error("Error calling contract procedure for proposal {}: {}", proposalId, e.getMessage());
            throw new RuntimeException(extractMessage(e), e);
        }
    }

    public void createJob(JobDTO jobDTO) {
        String username = SecurityUtils.getCurrentUsername();
        Account account = accountRepository.findByEmail(username);
        if (account == null) return;
        Profile profile = profileRepository.findByAccountId(account.getId()).orElse(null);
        if (profile == null) return;

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
}
