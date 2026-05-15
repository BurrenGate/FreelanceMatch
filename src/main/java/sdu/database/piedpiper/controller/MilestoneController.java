package sdu.database.piedpiper.controller;

import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.CreateMilestoneRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.MilestoneDTO;
import sdu.database.piedpiper.dto.response.PaymentSummaryDTO;
import sdu.database.piedpiper.service.MilestoneService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/contracts")
public class MilestoneController {

    private static final Logger log = LoggerFactory.getLogger(MilestoneController.class);
    private final MilestoneService milestoneService;

    public MilestoneController(MilestoneService milestoneService) {
        this.milestoneService = milestoneService;
    }

    @PostMapping("/{contractId}/milestones")
    public ResponseEntity<ApiResponse<Map<String, Long>>> createMilestone(
            @PathVariable Long contractId,
            @Valid @RequestBody CreateMilestoneRequest request) {
        log.debug("POST /api/contracts/{}/milestones", contractId);
        try {
            Long milestoneId = milestoneService.createMilestone(contractId, request);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Milestone created successfully", Map.of("milestoneId", milestoneId)));
        } catch (IllegalArgumentException e) {
            log.error("Invalid milestone request: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            log.error("Error creating milestone: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to create milestone: " + e.getMessage()));
        }
    }

    @GetMapping("/{contractId}/milestones")
    public ResponseEntity<ApiResponse<List<MilestoneDTO>>> getContractMilestones(@PathVariable Long contractId) {
        log.debug("GET /api/contracts/{}/milestones", contractId);
        try {
            List<MilestoneDTO> milestones = milestoneService.getContractMilestones(contractId);
            return ResponseEntity.ok(ApiResponse.ok(
                    milestones.isEmpty() ? "No milestones found" : "Retrieved " + milestones.size() + " milestone(s)",
                    milestones
            ));
        } catch (Exception e) {
            log.error("Error getting milestones: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to get milestones: " + e.getMessage()));
        }
    }

    @GetMapping("/{contractId}/payment-summary")
    public ResponseEntity<ApiResponse<PaymentSummaryDTO>> getPaymentSummary(@PathVariable Long contractId) {
        log.debug("GET /api/contracts/{}/payment-summary", contractId);
        try {
            PaymentSummaryDTO summary = milestoneService.getPaymentSummary(contractId);
            return ResponseEntity.ok(ApiResponse.ok("Payment summary retrieved successfully", summary));
        } catch (Exception e) {
            log.error("Error getting payment summary: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to get payment summary: " + e.getMessage()));
        }
    }

    @PutMapping("/{contractId}/milestones/{milestoneId}/status")
    public ResponseEntity<ApiResponse<Map<String, String>>> updateMilestoneStatus(
            @PathVariable Long contractId,
            @PathVariable Long milestoneId,
            @RequestBody Map<String, String> request) {
        log.debug("PUT /api/contracts/{}/milestones/{}/status", contractId, milestoneId);
        try {
            String status = request.get("status");
            if (status == null || status.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Status is required"));
            }
            
            String result = milestoneService.updateMilestoneStatus(milestoneId, status);
            return ResponseEntity.ok(ApiResponse.ok(
                    "Milestone status updated to " + result,
                    Map.of("status", result)
            ));
        } catch (Exception e) {
            log.error("Error updating milestone status: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to update milestone status: " + e.getMessage()));
        }
    }

    @PostMapping("/{contractId}/milestones/{milestoneId}/pay")
    public ResponseEntity<ApiResponse<Map<String, Long>>> payMilestone(
            @PathVariable Long contractId,
            @PathVariable Long milestoneId) {
        log.debug("POST /api/contracts/{}/milestones/{}/pay", contractId, milestoneId);
        try {
            Long transactionId = milestoneService.payMilestone(milestoneId);
            return ResponseEntity.ok(ApiResponse.ok(
                    "Milestone paid successfully. Transaction created.",
                    Map.of("transactionId", transactionId)
            ));
        } catch (Exception e) {
            log.error("Error paying milestone: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to pay milestone: " + e.getMessage()));
        }
    }
}
