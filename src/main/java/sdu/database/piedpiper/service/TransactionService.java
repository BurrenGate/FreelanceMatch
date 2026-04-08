package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.model.Transaction;
import sdu.database.piedpiper.repository.TransactionRepository;

import java.util.List;
import java.util.Optional;

@Service
public class TransactionService {

    private static final Logger log = LoggerFactory.getLogger(TransactionService.class);
    private final TransactionRepository transactionRepository;

    public TransactionService(TransactionRepository transactionRepository) {
        this.transactionRepository = transactionRepository;
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

    public Transaction createTransaction(Transaction transaction) {
        log.info("Creating new transaction for contract: {}", transaction.getContractId());
        if (transaction.getAmount() == null || transaction.getAmount().signum() <= 0) {
            throw new IllegalArgumentException("Transaction amount must be greater than zero");
        }
        return transactionRepository.save(transaction);
    }

    public Transaction updateTransaction(Long id, Transaction transaction) {
        log.info("Updating transaction: {}", id);
        Optional<Transaction> existing = transactionRepository.findById(id);
        if (existing.isPresent()) {
            if (transaction.getAmount() == null || transaction.getAmount().signum() <= 0) {
                throw new IllegalArgumentException("Transaction amount must be greater than zero");
            }
            transaction.setId(id);
            return transactionRepository.save(transaction);
        }
        throw new RuntimeException("Transaction not found with id: " + id);
    }

    public void deleteTransaction(Long id) {
        log.info("Deleting transaction: {}", id);
        Optional<Transaction> existing = transactionRepository.findById(id);
        if (existing.isPresent()) {
            transactionRepository.deleteById(id);
        } else {
            throw new RuntimeException("Transaction not found with id: " + id);
        }
    }
}
