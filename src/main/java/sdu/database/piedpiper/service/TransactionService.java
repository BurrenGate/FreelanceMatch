package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.TransactionRequest;
import sdu.database.piedpiper.dto.response.TransactionManageResponse;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.exception.NotFoundException;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.Contract;
import sdu.database.piedpiper.model.Job;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.model.Transaction;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.ContractRepository;
import sdu.database.piedpiper.repository.JobRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.repository.TransactionRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;
import java.util.Optional;

@Service
public class TransactionService {

    private static final Logger log = LoggerFactory.getLogger(TransactionService.class);
    private final TransactionRepository transactionRepository;
    private final ContractRepository contractRepository;
    private final JobRepository jobRepository;
    private final AccountRepository accountRepository;
    private final ProfileRepository profileRepository;

    public TransactionService(TransactionRepository transactionRepository,
                              ContractRepository contractRepository,
                              JobRepository jobRepository,
                              AccountRepository accountRepository,
                              ProfileRepository profileRepository) {
        this.transactionRepository = transactionRepository;
        this.contractRepository = contractRepository;
        this.jobRepository = jobRepository;
        this.accountRepository = accountRepository;
        this.profileRepository = profileRepository;
    }

    public List<Transaction> getAllTransactions() {
        log.info("Fetching all transactions");
        return transactionRepository.findAll();
    }

    public Optional<Transaction> getTransactionById(Long id) {
        log.info("Fetching transaction with id: {}", id);
        return transactionRepository.findById(id);
    }

    public List<Transaction> getTransactionsByContractId(Long contractId) {
        log.info("Fetching transactions for contract: {}", contractId);
        return transactionRepository.findByContractId(contractId);
    }

    public List<Transaction> getTransactionsByType(String type) {
        log.info("Fetching transactions by type: {}", type);
        return transactionRepository.findByType(type);
    }

    public Transaction createTransaction(TransactionRequest request) {
        log.info("Creating new transaction for contract: {}", request.getContractId());
        if (request.getAmount() == null || request.getAmount().signum() <= 0) {
            throw new IllegalArgumentException("Transaction amount must be greater than zero");
        }

        Contract contract = contractRepository.findById(request.getContractId())
                .orElseThrow(() -> new NotFoundException("Contract not found with id: " + request.getContractId()));
        ensureCurrentUserOwnsContract(contract);

        Transaction transaction = new Transaction();
        transaction.setContractId(request.getContractId());
        transaction.setAmount(request.getAmount());
        transaction.setType(request.getType());
        return transactionRepository.save(transaction);
    }

    public Transaction updateTransaction(Long id, TransactionRequest request) {
        log.info("Updating transaction: {}", id);
        Optional<Transaction> existing = transactionRepository.findById(id);
        if (existing.isPresent()) {
            if (request.getAmount() == null || request.getAmount().signum() <= 0) {
                throw new IllegalArgumentException("Transaction amount must be greater than zero");
            }
            Contract contract = contractRepository.findById(request.getContractId())
                    .orElseThrow(() -> new NotFoundException("Contract not found with id: " + request.getContractId()));
            ensureCurrentUserOwnsContract(contract);

            Transaction transaction = existing.get();
            transaction.setId(id);
            transaction.setContractId(request.getContractId());
            transaction.setAmount(request.getAmount());
            transaction.setType(request.getType());
            return transactionRepository.save(transaction);
        }
        throw new NotFoundException("Transaction not found with id: " + id);
    }

    public void deleteTransaction(Long id) {
        log.info("Deleting transaction: {}", id);
        Optional<Transaction> existing = transactionRepository.findById(id);
        if (existing.isPresent()) {
            Contract contract = contractRepository.findById(existing.get().getContractId())
                    .orElseThrow(() -> new NotFoundException("Contract not found with id: " + existing.get().getContractId()));
            ensureCurrentUserOwnsContract(contract);
            transactionRepository.deleteById(id);
        } else {
            throw new NotFoundException("Transaction not found with id: " + id);
        }
    }

    public List<TransactionManageResponse> getManagedTransactions(Long contractId, String type) {
        return transactionRepository.getManagedTransactions(contractId, type, getCurrentAdminEmail());
    }

    public TransactionManageResponse getManagedTransactionById(Long id) {
        return transactionRepository.getManagedTransactionById(id, getCurrentAdminEmail());
    }

    public TransactionManageResponse createManagedTransaction(Long contractId, java.math.BigDecimal amount, String type) {
        return transactionRepository.createManagedTransaction(contractId, amount, type, getCurrentAdminEmail());
    }

    public TransactionManageResponse updateManagedTransaction(Long id, Long contractId, java.math.BigDecimal amount, String type) {
        return transactionRepository.updateManagedTransaction(id, contractId, amount, type, getCurrentAdminEmail());
    }

    public void deleteManagedTransaction(Long id) {
        transactionRepository.deleteManagedTransaction(id, getCurrentAdminEmail());
    }

    private void ensureCurrentUserOwnsContract(Contract contract) {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        Account account = accountRepository.findByEmail(email);
        if (account == null) {
            throw new NotFoundException("Account not found for authenticated user");
        }
        Profile profile = profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found for authenticated user"));

        if (profile.getId().equals(contract.getFreelancerId())) {
            return;
        }
        Job job = jobRepository.findById(contract.getJobId())
                .orElseThrow(() -> new NotFoundException("Job not found for contract " + contract.getId()));
        if (!profile.getId().equals(job.getClientId())) {
            throw new ForbiddenOperationException("You can only modify transactions of your own contracts");
        }
    }

    private String getCurrentAdminEmail() {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null || email.isBlank()) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        if (!SecurityUtils.isAdmin()) {
            throw new ForbiddenOperationException("Only admins can manage transactions");
        }
        return email;
    }
}
