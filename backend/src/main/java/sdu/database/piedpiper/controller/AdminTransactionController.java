package sdu.database.piedpiper.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.TransactionUpsertRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.TransactionManageResponse;
import sdu.database.piedpiper.service.TransactionService;

import java.util.List;

@RestController
@RequestMapping("/api/transactions/manage")
public class AdminTransactionController {

    private final TransactionService transactionService;

    public AdminTransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<TransactionManageResponse>>> getManagedTransactions(
            @RequestParam(required = false) Long contractId,
            @RequestParam(required = false) String type
    ) {
        List<TransactionManageResponse> transactions = transactionService.getManagedTransactions(contractId, type);
        return ResponseEntity.ok(ApiResponse.ok("Transactions retrieved successfully", transactions));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<TransactionManageResponse>> getManagedTransactionById(@PathVariable Long id) {
        TransactionManageResponse transaction = transactionService.getManagedTransactionById(id);
        return ResponseEntity.ok(ApiResponse.ok("Transaction retrieved successfully", transaction));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<TransactionManageResponse>> createManagedTransaction(
            @Valid @RequestBody TransactionUpsertRequest request
    ) {
        TransactionManageResponse created = transactionService.createManagedTransaction(
                request.getContractId(),
                request.getAmount(),
                request.getType()
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Transaction created successfully", created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<TransactionManageResponse>> updateManagedTransaction(
            @PathVariable Long id,
            @Valid @RequestBody TransactionUpsertRequest request
    ) {
        TransactionManageResponse updated = transactionService.updateManagedTransaction(
                id,
                request.getContractId(),
                request.getAmount(),
                request.getType()
        );
        return ResponseEntity.ok(ApiResponse.ok("Transaction updated successfully", updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteManagedTransaction(@PathVariable Long id) {
        transactionService.deleteManagedTransaction(id);
        return ResponseEntity.ok(ApiResponse.ok("Transaction deleted successfully", null));
    }
}
