package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.RegisterRequest;
import sdu.database.piedpiper.dto.response.AccountResponse;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;

@Service
public class AccountService {

    private static final Logger log = LoggerFactory.getLogger(AccountService.class);
    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;

    public AccountService(AccountRepository accountRepository, PasswordEncoder passwordEncoder) {
        this.accountRepository = accountRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public void registerAccount(RegisterRequest request) {
        log.info("Attempting to register user with email: {}", request.getEmail());

        String encodedPassword = passwordEncoder.encode(request.getPassword());

        accountRepository.registerUserWithRole(
                request.getEmail(),
                encodedPassword,
                request.getRoleId(),
                request.getFirstName(),
                request.getLastName(),
                request.getHourlyRate()
        );

        log.info("User {} successfully registered", request.getEmail());
    }

    public Account findByEmail(String email) {
        log.debug("Fetching account by email: {}", email);
        return accountRepository.findByEmail(email);
    }

    public List<AccountResponse> getAccounts(String status) {
        return accountRepository.getAccounts(status, getCurrentAdminEmail());
    }

    public AccountResponse getAccountById(Long accountId) {
        return accountRepository.getAccountById(accountId, getCurrentAdminEmail());
    }

    public AccountResponse updateAccountStatus(Long accountId, String status) {
        String adminEmail = getCurrentAdminEmail();
        accountRepository.updateAccountStatus(accountId, status, adminEmail);
        return accountRepository.getAccountById(accountId, adminEmail);
    }

    public void changePassword(String oldPassword, String newPassword) {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }

        Account account = accountRepository.findByEmail(email);
        if (account == null) {
            throw new ForbiddenOperationException("Account not found");
        }

        if (!passwordEncoder.matches(oldPassword, account.getPasswordHash())) {
            throw new IllegalArgumentException("Current password is incorrect");
        }

        String newPasswordHash = passwordEncoder.encode(newPassword);
        accountRepository.changePassword(email, account.getPasswordHash(), newPasswordHash);
        
        log.info("Password changed successfully for user: {}", email);
    }

    public void updateLastLogin(String email) {
        accountRepository.updateLastLogin(email);
        log.debug("Last login updated for user: {}", email);
    }

    public void deactivateAccount() {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }

        try {
            accountRepository.deactivateAccount(email);
            log.info("Account deactivated successfully for user: {}", email);
        } catch (Exception e) {
            log.error("Failed to deactivate account for user {}: {}", email, e.getMessage());
            throw new IllegalStateException(e.getMessage());
        }
    }

    private String getCurrentAdminEmail() {
        if (!SecurityUtils.isAdmin()) {
            throw new ForbiddenOperationException("Only admins can manage accounts");
        }
        String email = SecurityUtils.getCurrentUsername();
        if (email == null || email.isBlank()) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        return email;
    }
}
