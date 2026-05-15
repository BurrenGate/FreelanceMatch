package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.TransactionRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.model.Transaction;
import sdu.database.piedpiper.security.SecurityUtils;
import sdu.database.piedpiper.service.TransactionService;

import java.util.List;

@RestController
@RequestMapping("/api/transactions")
public class TransactionController {

    private static final Logger log = LoggerFactory.getLogger(TransactionController.class);
    private final TransactionService transactionService;

    public TransactionController(TransactionService transactionService) {
        this.transactionService = transactionService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Transaction>>> getAllTransactions() {
        try {
            log.debug("GET /api/transactions");
            List<Transaction> transactions = transactionService.getAllTransactions();
            return ResponseEntity.ok(ApiResponse.ok(
                    transactions.isEmpty() ? "No transactions found" : "Retrieved " + transactions.size() + " transaction(s)",
                    transactions
            ));
        } catch (Exception ex) {
            log.error("Error getting all transactions: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Transaction>> getTransactionById(@PathVariable Long id) {
        try {
            log.debug("GET /api/transactions/{}", id);
            return transactionService.getTransactionById(id)
                    .map(transaction -> ResponseEntity.ok(ApiResponse.ok("Transaction retrieved successfully", transaction)))
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception ex) {
            log.error("Error getting transaction: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/contract/{contractId}")
    public ResponseEntity<ApiResponse<List<Transaction>>> getTransactionsByContractId(@PathVariable Long contractId) {
        try {
            log.debug("GET /api/transactions/contract/{}", contractId);
            List<Transaction> transactions = transactionService.getTransactionsByContractId(contractId);
            return ResponseEntity.ok(ApiResponse.ok(
                    transactions.isEmpty() ? "No transactions found for contract" : "Retrieved " + transactions.size() + " transaction(s)",
                    transactions
            ));
        } catch (Exception ex) {
            log.error("Error getting transactions by contract: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/type/{type}")
    public ResponseEntity<ApiResponse<List<Transaction>>> getTransactionsByType(@PathVariable String type) {
        try {
            log.debug("GET /api/transactions/type/{}", type);
            List<Transaction> transactions = transactionService.getTransactionsByType(type);
            return ResponseEntity.ok(ApiResponse.ok(
                    transactions.isEmpty() ? "No transactions found of type: " + type : "Retrieved " + transactions.size() + " transaction(s)",
                    transactions
            ));
        } catch (Exception ex) {
            log.error("Error getting transactions by type: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Transaction>> createTransaction(@Valid @RequestBody TransactionRequest transaction) {
        try {
            log.debug("POST /api/transactions");
            if (!SecurityUtils.hasAnyRole(1, 2)) {  // 1 = CLIENT, 2 = FREELANCER
                return ResponseEntity.status(403)
                        .body(ApiResponse.error("Insufficient permissions. Only clients and freelancers can create transactions."));
            }
            Transaction created = transactionService.createTransaction(transaction);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Transaction created successfully", created));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        } catch (Exception ex) {
            log.error("Error creating transaction: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Transaction>> updateTransaction(@PathVariable Long id, @Valid @RequestBody TransactionRequest transaction) {
        try {
            log.debug("PUT /api/transactions/{}", id);
            Transaction updated = transactionService.updateTransaction(id, transaction);
            return ResponseEntity.ok(ApiResponse.ok("Transaction updated successfully", updated));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        } catch (Exception ex) {
            log.error("Error updating transaction: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteTransaction(@PathVariable Long id) {
        try {
            log.debug("DELETE /api/transactions/{}", id);
            transactionService.deleteTransaction(id);
            return ResponseEntity.ok(ApiResponse.ok("Transaction deleted successfully", null));
        } catch (Exception ex) {
            log.error("Error deleting transaction: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }
}
