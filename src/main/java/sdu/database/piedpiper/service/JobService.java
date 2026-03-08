package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.model.FreelancerMatch;
import sdu.database.piedpiper.model.Job;
import sdu.database.piedpiper.repository.JobRepository;

import java.util.List;

@Service
public class JobService {

    private static final Logger log = LoggerFactory.getLogger(JobService.class);

    private final JobRepository jobRepository;

    public JobService(JobRepository jobRepository) {
        this.jobRepository = jobRepository;
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

