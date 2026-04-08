package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.SubmitProposalRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.model.Proposal;
import sdu.database.piedpiper.security.SecurityUtils;
import sdu.database.piedpiper.service.ProposalService;

import java.util.List;

@RestController
@RequestMapping("/api/proposals")
public class ProposalController {

    private static final Logger log = LoggerFactory.getLogger(ProposalController.class);
    private final ProposalService proposalService;

    public ProposalController(ProposalService proposalService) {
        this.proposalService = proposalService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Proposal>>> getAllProposals() {
        log.debug("GET /api/proposals");
        try {
            List<Proposal> proposals = proposalService.getAllProposals();
            return ResponseEntity.ok(ApiResponse.ok(
                    proposals.isEmpty() ? "No proposals found" : "Retrieved " + proposals.size() + " proposal(s)",
                    proposals
            ));
        } catch (Exception ex) {
            log.error("Error getting all proposals: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Proposal>> getProposalById(@PathVariable Long id) {
        log.debug("GET /api/proposals/{}", id);
        try {
            return proposalService.getProposalById(id)
                    .map(proposal -> ResponseEntity.ok(ApiResponse.ok("Proposal retrieved successfully", proposal)))
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception ex) {
            log.error("Error getting proposal: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @PostMapping("/submit")
    public ResponseEntity<ApiResponse<Void>> submitProposal(@RequestBody SubmitProposalRequest request) {
        log.debug("POST /api/proposals/submit");
        try {
            if (!SecurityUtils.isFreelancer()) {
                return ResponseEntity.status(403)
                        .body(ApiResponse.error("Insufficient permissions. Only freelancers can submit proposals."));
            }
            if (request.getJobId() == null || request.getFreelancerId() == null) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Job ID and Freelancer ID are required"));
            }
            if (request.getBidAmount() == null || request.getBidAmount().signum() <= 0) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Bid amount must be greater than zero"));
            }
            proposalService.submitProposal(request);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Proposal submitted successfully!", null));
        } catch (Exception e) {
            log.error("Error submitting proposal: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Proposal>> updateProposal(@PathVariable Long id, @RequestBody Proposal proposal) {
        log.debug("PUT /api/proposals/{}", id);
        try {
            if (proposal.getBidAmount() == null || proposal.getBidAmount().signum() <= 0) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Bid amount must be greater than zero"));
            }
            Proposal updated = proposalService.updateProposal(id, proposal);
            return ResponseEntity.ok(ApiResponse.ok("Proposal updated successfully", updated));
        } catch (Exception e) {
            log.error("Error updating proposal: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteProposal(@PathVariable Long id) {
        log.debug("DELETE /api/proposals/{}", id);
        try {
            proposalService.deleteProposal(id);
            return ResponseEntity.ok(ApiResponse.ok("Proposal deleted successfully", null));
        } catch (Exception e) {
            log.error("Error deleting proposal: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/job/{jobId}")
    public ResponseEntity<ApiResponse<List<Proposal>>> getProposalsByJobId(@PathVariable Long jobId) {
        log.debug("GET /api/proposals/job/{}", jobId);
        try {
            List<Proposal> proposals = proposalService.getProposalsForJob(jobId);
            return ResponseEntity.ok(ApiResponse.ok(
                    proposals.isEmpty() ? "No proposals found for this job" : "Retrieved " + proposals.size() + " proposal(s)",
                    proposals
            ));
        } catch (Exception e) {
            log.error("Error getting proposals by job: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to retrieve proposals: " + e.getMessage()));
        }
    }

    @PostMapping("/{proposalId}/accept")
    public ResponseEntity<ApiResponse<Void>> acceptProposal(@PathVariable Long proposalId) {
        log.debug("POST /api/proposals/{}/accept", proposalId);
        try {
            if (!SecurityUtils.isClient()) {
                return ResponseEntity.status(403)
                        .body(ApiResponse.error("Insufficient permissions. Only clients can accept proposals."));
            }
            if (proposalId == null || proposalId <= 0) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Valid proposal ID is required"));
            }
            proposalService.acceptProposal(proposalId);
            return ResponseEntity.ok(ApiResponse.ok(
                    "Proposal accepted! Contract created and job status changed to IN_PROGRESS.", null
            ));
        } catch (Exception e) {
            log.error("Error accepting proposal: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}