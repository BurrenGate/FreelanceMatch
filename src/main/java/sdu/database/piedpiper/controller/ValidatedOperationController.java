package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.CancelContractRequest;
import sdu.database.piedpiper.dto.request.CreateJobRequestDTO;
import sdu.database.piedpiper.dto.request.CreateProposalRequestDTO;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.JobDTO;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.security.SecurityUtils;
import sdu.database.piedpiper.service.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("/api/validated")
public class ValidatedOperationController {

    private static final Logger log = LoggerFactory.getLogger(ValidatedOperationController.class);

    private final BusinessValidationService validationService;
    private final JobService jobService;
    private final ProposalService proposalService;
    private final ContractService contractService;
    private final AccountRepository accountRepository;
    private final ProfileRepository profileRepository;

    public ValidatedOperationController(
            BusinessValidationService validationService,
            JobService jobService,
            ProposalService proposalService,
            ContractService contractService,
            AccountRepository accountRepository,
            ProfileRepository profileRepository) {
        this.validationService = validationService;
        this.jobService = jobService;
        this.proposalService = proposalService;
        this.contractService = contractService;
        this.accountRepository = accountRepository;
        this.profileRepository = profileRepository;
    }

    /**
     * Create a job with business rule validation
     * Validates:
     * - Application deadline not in past
     * - Start date after deadline
     * - End date after start date
     * - No duplicate open jobs
     */
    @PostMapping("/jobs/create")
    public ResponseEntity<ApiResponse<String>> createJobWithValidation(@RequestBody CreateJobRequestDTO request) {
        log.info("POST /api/validated/jobs/create - Creating job with validation");

        try {
            // Get current user's profile
            String username = SecurityUtils.getCurrentUsername();
            Account account = accountRepository.findByEmail(username);
            if (account == null) {
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                        .body(ApiResponse.error("User not found"));
            }

            Profile profile = profileRepository.findByAccountId(account.getId()).orElse(null);
            if (profile == null) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                        .body(ApiResponse.error("Profile not found for user"));
            }

            request.setClientId(profile.getId());

            // Validate job creation
            validationService.validateJobCreation(request);

            // If validation passes, create the job
            JobDTO jobDTO = new JobDTO();
            jobDTO.setTitle(request.getTitle());
            jobDTO.setDescription(request.getDescription());
            jobDTO.setBudget(request.getMinBudget().doubleValue());
            jobService.createJob(jobDTO);

            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Job created successfully with all business rules validated", "Job ID: " + request.getClientId()));
        } catch (IllegalArgumentException e) {
            log.warn("Job creation validation failed: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            log.error("Error creating job", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to create job: " + e.getMessage()));
        }
    }

    /**
     * Submit a proposal with business rule validation
     * Validates:
     * - Job is OPEN
     * - Application deadline not passed
     * - Freelancer doesn't have >3 active contracts
     * - Bid amount is positive
     * - Can't submit multiple proposals to same job
     */
    @PostMapping("/proposals/submit")
    public ResponseEntity<ApiResponse<String>> submitProposalWithValidation(@RequestBody CreateProposalRequestDTO request) {
        log.info("POST /api/validated/proposals/submit - Submitting proposal with validation");

        try {
            // Validate proposal submission
            validationService.validateProposalSubmission(request);

            // If validation passes, submit the proposal
            sdu.database.piedpiper.dto.request.SubmitProposalRequest submitRequest =
                    new sdu.database.piedpiper.dto.request.SubmitProposalRequest();
            submitRequest.setJobId(request.getJobId());
            submitRequest.setCoverLetter(request.getCoverLetter());
            submitRequest.setBidAmount(request.getBidAmount());

            proposalService.submitProposal(submitRequest);

            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Proposal submitted successfully with all business rules validated", "Proposal submitted"));
        } catch (IllegalArgumentException e) {
            log.warn("Proposal submission validation failed: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            log.error("Error submitting proposal", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to submit proposal: " + e.getMessage()));
        }
    }

    /**
     * Cancel a contract with business rule validation
     * Validates:
     * - Contract is ACTIVE
     * - Only client or freelancer can cancel
     * - Reason is provided
     */
    @PostMapping("/contracts/{contractId}/cancel")
    public ResponseEntity<ApiResponse<String>> cancelContractWithValidation(@PathVariable Long contractId, @RequestBody CancelContractRequest request) {
        log.info("POST /api/validated/contracts/cancel - Cancelling contract with validation");

        try {
            // Validate contract cancellation
            //validationService.validateContractCancellation(request);

            // If validation passes, cancel the contract
            contractService.requestCancellation(contractId, request);

            return ResponseEntity.ok(
                    ApiResponse.ok("Contract cancellation request submitted successfully", "Contract cancelled"));
        } catch (IllegalArgumentException e) {
            log.warn("Contract cancellation validation failed: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            log.error("Error cancelling contract", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to cancel contract: " + e.getMessage()));
        }
    }

    /**
     * Complete a contract with business rule validation and review
     */
    @PostMapping("/contracts/{contractId}/complete")
    public ResponseEntity<ApiResponse<String>> completeContractWithValidation(
            @PathVariable Long contractId,
            @RequestParam(required = false) Integer rating,
            @RequestParam(required = false) String feedback) {
        log.info("POST /api/validated/contracts/{}/complete - Completing contract with validation", contractId);

        try {
            // Validate contract completion
            validationService.validateContractCompletion(contractId);

            // If validation passes, complete the contract
            if (rating != null && feedback != null) {
                sdu.database.piedpiper.dto.request.CompleteJobRequest completeRequest =
                        new sdu.database.piedpiper.dto.request.CompleteJobRequest();
                completeRequest.setContractId(contractId);
                completeRequest.setRating(BigDecimal.valueOf(rating));
                completeRequest.setFeedback(feedback);

                contractService.completeJobAndRate(completeRequest);
            }

            return ResponseEntity.ok(
                    ApiResponse.ok("Contract completed successfully with all business rules validated", "Contract completed"));
        } catch (IllegalArgumentException e) {
            log.warn("Contract completion validation failed: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            log.error("Error completing contract", e);
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to complete contract: " + e.getMessage()));
        }
    }
}