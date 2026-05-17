package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.SqlParameter;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.CancelContractRequestDTO;
import sdu.database.piedpiper.dto.request.CreateJobRequestDTO;
import sdu.database.piedpiper.dto.request.CreateProposalRequestDTO;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;

/**
 * Service that handles all business logic validation through stored procedures.
 * This ensures that all business rules are enforced at the database layer.
 */
@Service
public class BusinessValidationService {

    private static final Logger log = LoggerFactory.getLogger(BusinessValidationService.class);
    private final JdbcTemplate jdbc;

    public BusinessValidationService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /**
     * Validate job creation with business rules:
     * - Application deadline cannot be in the past
     * - Start date must be after application deadline
     * - End date must be after start date
     * - Prevent duplicate open jobs with same title
     */
    public void validateJobCreation(CreateJobRequestDTO request) {
        log.info("Validating job creation for client {} with title '{}'",
                request.getClientId(), request.getTitle());
        try {
            jdbc.call(connection -> {
                var callableStatement = connection.prepareCall(
                        "{call job_market.validate_job_creation(?, ?, ?, ?, ?)}"
                );
                callableStatement.setLong(1, request.getClientId());
                callableStatement.setString(2, request.getTitle());
                callableStatement.setObject(3, request.getApplicationDeadline());
                callableStatement.setObject(4, request.getStartDate());
                callableStatement.setObject(5, request.getEndDate());
                return callableStatement;
            }, new ArrayList<SqlParameter>());
            log.info("Job creation validation passed");
        } catch (DataAccessException e) {
            log.error("Job validation failed: {}", e.getMessage());
            throw new IllegalArgumentException(extractErrorMessage(e));
        }
    }

    /**
     * Validate proposal submission with business rules:
     * - Job must be OPEN
     * - Application deadline must not have passed
     * - Freelancer cannot bid on own job
     * - Freelancer cannot have more than 3 active contracts
     * - Bid amount must be positive
     * - Freelancer cannot submit multiple proposals to same job
     */
    public void validateProposalSubmission(CreateProposalRequestDTO request) {
        log.info("Validating proposal submission from freelancer {} for job {}",
                request.getFreelancerId(), request.getJobId());
        try {
            jdbc.call(connection -> {
                var callableStatement = connection.prepareCall(
                        "{call job_market.validate_proposal_submission(?, ?, ?)}"
                );
                callableStatement.setLong(1, request.getJobId());
                callableStatement.setLong(2, request.getFreelancerId());
                callableStatement.setBigDecimal(3, request.getBidAmount());
                return callableStatement;
            }, new ArrayList<SqlParameter>());
            log.info("Proposal validation passed");
        } catch (DataAccessException e) {
            log.error("Proposal validation failed: {}", e.getMessage());
            throw new IllegalArgumentException(extractErrorMessage(e));
        }
    }

    /**
     * Validate contract creation with business rules:
     * - Job must be OPEN
     * - Proposal must be PENDING
     * - Freelancer must not exceed 3 active contracts
     */
    public void validateContractCreation(Long proposalId, Long jobId, Long freelancerId) {
        log.info("Validating contract creation for proposal {}, job {}, freelancer {}",
                proposalId, jobId, freelancerId);
        try {
            jdbc.call(connection -> {
                var callableStatement = connection.prepareCall(
                        "{call job_market.validate_contract_creation(?, ?, ?)}"
                );
                callableStatement.setLong(1, proposalId);
                callableStatement.setLong(2, jobId);
                callableStatement.setLong(3, freelancerId);
                return callableStatement;
            }, new ArrayList<SqlParameter>());
            log.info("Contract creation validation passed");
        } catch (DataAccessException e) {
            log.error("Contract creation validation failed: {}", e.getMessage());
            throw new IllegalArgumentException(extractErrorMessage(e));
        }
    }

    /**
     * Validate contract completion with business rules:
     * - Contract must be ACTIVE
     * - Contract must have positive amount
     */
    public void validateContractCompletion(Long contractId) {
        log.info("Validating contract completion for contract {}", contractId);
        try {
            jdbc.call(connection -> {
                var callableStatement = connection.prepareCall(
                        "{call job_market.validate_contract_completion(?)}"
                );
                callableStatement.setLong(1, contractId);
                return callableStatement;
            }, new ArrayList<SqlParameter>());
            log.info("Contract completion validation passed");
        } catch (DataAccessException e) {
            log.error("Contract completion validation failed: {}", e.getMessage());
            throw new IllegalArgumentException(extractErrorMessage(e));
        }
    }

    /**
     * Validate review submission with business rules:
     * - Rating must be 1-5
     * - Contract must exist and be completed
     * - Reviewer cannot be the freelancer
     * - Each reviewer can only review once per contract
     */
    public void validateReviewSubmission(Long contractId, Long reviewerId, Integer rating) {
        log.info("Validating review submission for contract {} from reviewer {}",
                contractId, reviewerId);
        try {
            jdbc.call(connection -> {
                var callableStatement = connection.prepareCall(
                        "{call job_market.validate_review_submission(?, ?, ?)}"
                );
                callableStatement.setLong(1, contractId);
                callableStatement.setLong(2, reviewerId);
                callableStatement.setInt(3, rating);
                return callableStatement;
            }, new ArrayList<SqlParameter>());
            log.info("Review validation passed");
        } catch (DataAccessException e) {
            log.error("Review validation failed: {}", e.getMessage());
            throw new IllegalArgumentException(extractErrorMessage(e));
        }
    }

    /**
     * Validate contract cancellation with business rules:
     * - Contract must be ACTIVE
     * - Only client or freelancer can cancel
     * - Cancellation reason is required
     */
    public void validateContractCancellation(CancelContractRequestDTO request) {
        log.info("Validating contract cancellation for contract {}", request.getContractId());
        try {
            jdbc.call(connection -> {
                var callableStatement = connection.prepareCall(
                        "{call job_market.validate_contract_cancellation(?, ?, ?)}"
                );
                callableStatement.setLong(1, request.getContractId());
                callableStatement.setLong(2, request.getCancelledBy());
                callableStatement.setString(3, request.getCancellationReason());
                return callableStatement;
            }, new ArrayList<SqlParameter>());
            log.info("Contract cancellation validation passed");
        } catch (DataAccessException e) {
            log.error("Contract cancellation validation failed: {}", e.getMessage());
            throw new IllegalArgumentException(extractErrorMessage(e));
        }
    }

    /**
     * Extract meaningful error message from database exception
     */
    private String extractErrorMessage(DataAccessException e) {
        String message = e.getMessage();
        if (message == null) {
            return "Database validation failed";
        }

        // Extract the actual error from PostgreSQL exception
        if (message.contains("ERROR")) {
            int startIndex = message.indexOf("ERROR");
            int endIndex = message.indexOf(";", startIndex);
            if (endIndex == -1) {
                endIndex = message.length();
            }
            return message.substring(startIndex, endIndex).replace("ERROR:", "").trim();
        }

        return message;
    }
}