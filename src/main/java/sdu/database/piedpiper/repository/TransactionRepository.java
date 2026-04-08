package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.Transaction;

import java.util.List;
import java.util.Optional;

@Repository
public class TransactionRepository {

    private static final Logger log = LoggerFactory.getLogger(TransactionRepository.class);
    private final JdbcTemplate jdbc;

    public TransactionRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<Transaction> TRANSACTION_MAPPER = (rs, rowNum) -> {
        Transaction t = new Transaction();
        t.setId(rs.getLong("id"));
        t.setContractId(rs.getLong("contract_id"));
        t.setAmount(rs.getBigDecimal("amount"));
        t.setType(rs.getString("type"));
        t.setCreatedAt(rs.getTimestamp("created_at") != null
                ? rs.getTimestamp("created_at").toLocalDateTime()
                : null);
        return t;
    };

    public List<Transaction> findAll() {
        String sql = "SELECT id, contract_id, amount, type, created_at FROM transactions ORDER BY created_at DESC";
        log.debug("Executing findAll() transactions query");
        return jdbc.query(sql, TRANSACTION_MAPPER);
    }

    public Optional<Transaction> findById(Long id) {
        String sql = "SELECT id, contract_id, amount, type, created_at FROM transactions WHERE id = ?";
        try {
            Transaction transaction = jdbc.queryForObject(sql, TRANSACTION_MAPPER, id);
            return Optional.of(transaction);
        } catch (Exception e) {
            log.debug("Transaction not found with id: {}", id);
            return Optional.empty();
        }
    }

    public List<Transaction> findByContractId(Long contractId) {
        String sql = "SELECT id, contract_id, amount, type, created_at FROM transactions WHERE contract_id = ? ORDER BY created_at DESC";
        return jdbc.query(sql, TRANSACTION_MAPPER, contractId);
    }

    public List<Transaction> findByType(String type) {
        String sql = "SELECT id, contract_id, amount, type, created_at FROM transactions WHERE type = ? ORDER BY created_at DESC";
        return jdbc.query(sql, TRANSACTION_MAPPER, type);
    }

    public Transaction save(Transaction transaction) {
        if (transaction.getId() != null) {
            String sql = "UPDATE transactions SET contract_id = ?, amount = ?, type = ? WHERE id = ?";
            jdbc.update(sql, transaction.getContractId(), transaction.getAmount(), transaction.getType(), transaction.getId());
            log.info("Transaction updated: {}", transaction.getId());
        } else {
            String sql = "INSERT INTO transactions (contract_id, amount, type) VALUES (?, ?, ?)";
            jdbc.update(sql, transaction.getContractId(), transaction.getAmount(), transaction.getType());
            log.info("Transaction created for contract: {}", transaction.getContractId());
        }
        return transaction;
    }

    public void deleteById(Long id) {
        String sql = "DELETE FROM transactions WHERE id = ?";
        int deleted = jdbc.update(sql, id);
        if (deleted > 0) {
            log.info("Transaction deleted: {}", id);
        } else {
            log.warn("No transaction found with id: {}", id);
        }
    }
}
