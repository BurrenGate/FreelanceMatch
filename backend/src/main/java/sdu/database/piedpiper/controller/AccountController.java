package sdu.database.piedpiper.controller;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.ChangePasswordRequest;
import sdu.database.piedpiper.dto.request.UpdateAccountStatusRequest;
import sdu.database.piedpiper.dto.response.AccountResponse;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.service.AccountService;

import java.util.List;

@RestController
@RequestMapping("/api/accounts")
public class AccountController {

    private final AccountService accountService;

    public AccountController(AccountService accountService) {
        this.accountService = accountService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<AccountResponse>>> getAccounts(@RequestParam(required = false) String status) {
        List<AccountResponse> accounts = accountService.getAccounts(status);
        return ResponseEntity.ok(ApiResponse.ok("Accounts retrieved successfully", accounts));
    }

    @GetMapping("/{accountId}")
    public ResponseEntity<ApiResponse<AccountResponse>> getAccountById(@PathVariable Long accountId) {
        AccountResponse account = accountService.getAccountById(accountId);
        return ResponseEntity.ok(ApiResponse.ok("Account retrieved successfully", account));
    }

    @PatchMapping("/{accountId}/status")
    public ResponseEntity<ApiResponse<AccountResponse>> updateAccountStatus(@PathVariable Long accountId,
                                                                            @Valid @RequestBody UpdateAccountStatusRequest request) {
        AccountResponse response = accountService.updateAccountStatus(accountId, request.getStatus());
        return ResponseEntity.ok(ApiResponse.ok("Account status updated", response));
    }

    @PostMapping("/change-password")
    public ResponseEntity<ApiResponse<Void>> changePassword(@Valid @RequestBody ChangePasswordRequest request) {
        if (request.getCurrentPassword() == null || request.getCurrentPassword().isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Current password is required"));
        }
        if (request.getNewPassword() == null || request.getNewPassword().isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("New password is required"));
        }
        if (request.getConfirmPassword() == null || request.getConfirmPassword().isBlank()) {
            return ResponseEntity.badRequest().body(ApiResponse.error("Confirm password is required"));
        }
        if (!request.getNewPassword().equals(request.getConfirmPassword())) {
            return ResponseEntity.badRequest().body(ApiResponse.error("New password and confirm password do not match"));
        }
        if (request.getNewPassword().length() < 6) {
            return ResponseEntity.badRequest().body(ApiResponse.error("New password must be at least 6 characters"));
        }
        
        try {
            accountService.changePassword(request.getCurrentPassword(), request.getNewPassword());
            return ResponseEntity.ok(ApiResponse.ok("Password changed successfully", null));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/deactivate")
    public ResponseEntity<ApiResponse<Void>> deactivateAccount() {
        try {
            accountService.deactivateAccount();
            return ResponseEntity.ok(ApiResponse.ok("Account deactivated successfully", null));
        } catch (IllegalStateException e) {
            return ResponseEntity.badRequest().body(ApiResponse.error(e.getMessage()));
        }
    }
}
