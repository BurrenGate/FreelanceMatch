package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.model.FreelancerMatch;
import sdu.database.piedpiper.model.Job;
import sdu.database.piedpiper.repository.JobRepository;

import java.util.List;

/**
 * Service layer – sits between the controller and repository.
 * Translates database exceptions into descriptive messages
 * so the controller can return clean API responses.
 */
@Service
public class JobService {

    private static final Logger log = LoggerFactory.getLogger(JobService.class);

    private final JobRepository jobRepository;

    public JobService(JobRepository jobRepository) {
        this.jobRepository = jobRepository;
    }

    /**
     * Returns all jobs (for the job list UI).
     */
    public List<Job> getAllJobs() {
        log.info("Fetching all jobs");
        return jobRepository.findAll();
    }

    /**
     * Triggers the CURSOR procedure and returns matching freelancers.
     *
     * @param jobId the job to match against
     * @return list of recommended freelancers with skill-match percentage
     */
    public List<FreelancerMatch> getRecommendedFreelancers(Long jobId) {
        log.info("Getting recommended freelancers for job {}", jobId);
        try {
            return jobRepository.findRecommendedFreelancers(jobId);
        } catch (DataAccessException e) {
            // DataAccessException wraps JDBC / SQL errors thrown by Spring
            log.error("Error calling matching procedure for job {}: {}", jobId, e.getMessage());
            throw new RuntimeException("Matching procedure failed: " + extractMessage(e), e);
        }
    }

    /**
     * Triggers the NESTED BLOCK procedure to accept a proposal.
     *
     * @param proposalId the proposal to accept
     * @throws RuntimeException if the database procedure raises an exception
     *                          (e.g. proposal not pending, job not open)
     */
    public void acceptProposal(Long proposalId) {
        log.info("Accepting proposal {}", proposalId);
        try {
            jobRepository.finalizeProposalAndCreateContract(proposalId);
        } catch (DataAccessException e) {
            log.error("Error calling contract procedure for proposal {}: {}", proposalId, e.getMessage());
            // Extract the PostgreSQL RAISE EXCEPTION message and surface it to the API caller
            throw new RuntimeException(extractMessage(e), e);
        }
    }

    /**
     * Pulls the most meaningful part of the exception message.
     * PostgreSQL error messages are usually nested inside the cause chain.
     */
    private String extractMessage(DataAccessException e) {
        Throwable cause = e.getMostSpecificCause();
        String msg = cause.getMessage();
        // PostgreSQL error messages contain "ERROR: <message>" – strip the prefix
        if (msg != null && msg.contains("ERROR:")) {
            int idx = msg.indexOf("ERROR:") + 6;
            return msg.substring(idx).split("\n")[0].trim();
        }
        return msg != null ? msg : "Unknown database error";
    }
}

