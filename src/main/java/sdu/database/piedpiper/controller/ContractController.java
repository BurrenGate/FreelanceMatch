package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.CancelContractRequest;
import sdu.database.piedpiper.dto.request.CompleteJobRequest;
import sdu.database.piedpiper.dto.request.ContractRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.ContractDetailsDTO;
import sdu.database.piedpiper.model.Contract;
import sdu.database.piedpiper.security.SecurityUtils;
import sdu.database.piedpiper.service.ContractService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/contracts")
public class ContractController {

    private static final Logger log = LoggerFactory.getLogger(ContractController.class);
    private final ContractService contractService;

    public ContractController(ContractService contractService) {
        this.contractService = contractService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Contract>>> getAllContracts() {
        log.debug("GET /api/contracts");
        try {
            List<Contract> contracts = contractService.getAllContracts();
            return ResponseEntity.ok(ApiResponse.ok(
                    contracts.isEmpty() ? "No contracts found" : "Retrieved " + contracts.size() + " contract(s)",
                    contracts
            ));
        } catch (Exception ex) {
            log.error("Error getting all contracts: {}", ex.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to retrieve contracts: " + ex.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Contract>> getContractById(@PathVariable Long id) {
        log.debug("GET /api/contracts/{}", id);
        try {
            return contractService.getContractById(id)
                    .map(contract -> ResponseEntity.ok(ApiResponse.ok("Contract retrieved successfully", contract)))
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception ex) {
            log.error("Error getting contract: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<Contract>>> getMyContracts() {
        log.debug("GET /api/contracts/my");
        try {
            if (!SecurityUtils.hasAnyRole(1, 2)) {  // 1 = CLIENT, 2 = FREELANCER
                return ResponseEntity.status(403)
                        .body(ApiResponse.error("Insufficient permissions. Only clients and freelancers can view their contracts."));
            }
            List<Contract> contracts = contractService.getMyContracts();
            return ResponseEntity.ok(ApiResponse.ok(
                    contracts == null || contracts.isEmpty() ? "No contracts found" : "Retrieved " + contracts.size() + " contract(s)",
                    contracts != null ? contracts : new java.util.ArrayList<>()
            ));
        } catch (Exception ex) {
            log.error("Error getting my contracts: {}", ex.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to retrieve contracts: " + ex.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Contract>> createContract(@Valid @RequestBody ContractRequest contract) {
        log.debug("POST /api/contracts");
        try {
            Contract created = contractService.createContract(contract);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Contract created successfully", created));
        } catch (Exception e) {
            log.error("Error creating contract: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to create contract: " + e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Contract>> updateContract(@PathVariable Long id, @Valid @RequestBody ContractRequest contract) {
        log.debug("PUT /api/contracts/{}", id);
        try {
            Contract updated = contractService.updateContract(id, contract);
            return ResponseEntity.ok(ApiResponse.ok("Contract updated successfully", updated));
        } catch (Exception e) {
            log.error("Error updating contract: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to update contract: " + e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteContract(@PathVariable Long id) {
        log.debug("DELETE /api/contracts/{}", id);
        try {
            contractService.deleteContract(id);
            return ResponseEntity.ok(ApiResponse.ok("Contract deleted successfully", null));
        } catch (Exception e) {
            log.error("Error deleting contract: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to delete contract: " + e.getMessage()));
        }
    }

    @PostMapping("/{id}/complete")
    public ResponseEntity<ApiResponse<Void>> completeContract(@PathVariable Long id, @Valid @RequestBody CompleteJobRequest request) {
        log.debug("POST /api/contracts/{}/complete", id);
        try {
            if (!SecurityUtils.hasAnyRole(1, 2)) {  // 1 = CLIENT, 2 = FREELANCER
                return ResponseEntity.status(403)
                        .body(ApiResponse.error("Insufficient permissions. Only clients and freelancers can complete contracts."));
            }
            request.setContractId(id);
            contractService.completeJobAndRate(request);
            return ResponseEntity.ok(ApiResponse.ok(
                    "Contract successfully completed! Payment processed and review saved.", null
            ));
        } catch (Exception e) {
            log.error("Error completing contract: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/{contractId}/last-transaction")
    public ResponseEntity<ApiResponse<java.util.Map<String, Object>>> getLastTransactionAmount(@PathVariable Long contractId) {
        log.debug("GET /api/contracts/{}/last-transaction", contractId);
        try {
            java.math.BigDecimal amount = contractService.getLastTransactionAmount(contractId);
            java.util.Map<String, Object> result = new java.util.HashMap<>();
            result.put("contractId", contractId);
            result.put("lastTransactionAmount", amount);
            return ResponseEntity.ok(ApiResponse.ok("Last transaction amount retrieved", result));
        } catch (Exception e) {
            log.error("Error getting last transaction: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/{contractId}/details")
    public ResponseEntity<ApiResponse<ContractDetailsDTO>> getContractDetails(@PathVariable Long contractId) {
        log.debug("GET /api/contracts/{}/details", contractId);
        try {
            ContractDetailsDTO details = contractService.getContractDetails(contractId);
            return ResponseEntity.ok(ApiResponse.ok("Contract details retrieved successfully", details));
        } catch (Exception e) {
            log.error("Error getting contract details: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{contractId}/cancel/request")
    public ResponseEntity<ApiResponse<Map<String, String>>> requestCancellation(
            @PathVariable Long contractId,
            @Valid @RequestBody CancelContractRequest request) {
        log.debug("POST /api/contracts/{}/cancel/request", contractId);
        try {
            String result = contractService.requestCancellation(contractId, request);
            return ResponseEntity.ok(ApiResponse.ok(
                    "Cancellation request sent. Waiting for confirmation from the other party.",
                    Map.of("status", result)
            ));
        } catch (Exception e) {
            log.error("Error requesting cancellation: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{contractId}/cancel/confirm")
    public ResponseEntity<ApiResponse<Map<String, String>>> confirmCancellation(@PathVariable Long contractId) {
        log.debug("POST /api/contracts/{}/cancel/confirm", contractId);
        try {
            String result = contractService.confirmCancellation(contractId);
            return ResponseEntity.ok(ApiResponse.ok(
                    "Contract cancelled successfully. Job has been reopened.",
                    Map.of("status", result)
            ));
        } catch (Exception e) {
            log.error("Error confirming cancellation: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/{contractId}/cancel/reject")
    public ResponseEntity<ApiResponse<Map<String, String>>> rejectCancellationRequest(@PathVariable Long contractId) {
        log.debug("POST /api/contracts/{}/cancel/reject", contractId);
        try {
            String result = contractService.rejectCancellationRequest(contractId);
            return ResponseEntity.ok(ApiResponse.ok(
                    "Cancellation request rejected. Contract remains active.",
                    Map.of("status", result)
            ));
        } catch (Exception e) {
            log.error("Error rejecting cancellation: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}
