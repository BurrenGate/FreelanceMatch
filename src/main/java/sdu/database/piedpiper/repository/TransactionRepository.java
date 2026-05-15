package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.TransactionManageResponse;
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
        String sql = "SELECT * FROM app_management.get_transactions()";
        log.debug("Executing findAll() transactions query");
        return jdbc.query(sql, TRANSACTION_MAPPER);
    }

    public Optional<Transaction> findById(Long id) {
        String sql = "SELECT * FROM app_management.get_transaction_by_id(?)";
        try {
            Transaction transaction = jdbc.queryForObject(sql, TRANSACTION_MAPPER, id);
            return Optional.of(transaction);
        } catch (Exception e) {
            log.debug("Transaction not found with id: {}", id);
            return Optional.empty();
        }
    }

    public List<Transaction> findByContractId(Long contractId) {
        String sql = "SELECT * FROM app_management.get_transactions_by_contract(?)";
        return jdbc.query(sql, TRANSACTION_MAPPER, contractId);
    }

    public List<Transaction> findByType(String type) {
        String sql = "SELECT * FROM app_management.get_transactions_by_type(?)";
        return jdbc.query(sql, TRANSACTION_MAPPER, type);
    }

    public Transaction save(Transaction transaction) {
        String sql = "CALL app_management.upsert_transaction(?, ?, ?, ?)";
        jdbc.update(sql, transaction.getId(), transaction.getContractId(), transaction.getAmount(), transaction.getType());
        return transaction;
    }

    public void deleteById(Long id) {
        String sql = "CALL app_management.delete_transaction(?)";
        int deleted = jdbc.update(sql, id);
        if (deleted > 0) {
            log.info("Transaction deleted: {}", id);
        } else {
            log.warn("No transaction found with id: {}", id);
        }
    }

    public java.util.List<TransactionManageResponse> getManagedTransactions(Long contractId, String type, String adminEmail) {
        String sql = "SELECT * FROM admin_management.get_transactions(?, ?, ?)";
        return jdbc.query(sql, (rs, rowNum) -> TransactionManageResponse.builder()
                .id(rs.getLong("id"))
                .contractId(rs.getLong("contract_id"))
                .amount(rs.getBigDecimal("amount"))
                .type(rs.getString("type"))
                .createdAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null)
                .build(), contractId, type, adminEmail);
    }

    public TransactionManageResponse getManagedTransactionById(Long id, String adminEmail) {
        String sql = "SELECT * FROM admin_management.get_transaction_by_id(?, ?)";
        return jdbc.queryForObject(sql, (rs, rowNum) -> TransactionManageResponse.builder()
                .id(rs.getLong("id"))
                .contractId(rs.getLong("contract_id"))
                .amount(rs.getBigDecimal("amount"))
                .type(rs.getString("type"))
                .createdAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null)
                .build(), id, adminEmail);
    }

    public TransactionManageResponse createManagedTransaction(Long contractId, java.math.BigDecimal amount, String type, String adminEmail) {
        String sql = "SELECT * FROM admin_management.create_transaction(?, ?, ?, ?)";
        return jdbc.queryForObject(sql, (rs, rowNum) -> TransactionManageResponse.builder()
                .id(rs.getLong("id"))
                .contractId(rs.getLong("contract_id"))
                .amount(rs.getBigDecimal("amount"))
                .type(rs.getString("type"))
                .createdAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null)
                .build(), contractId, amount, type, adminEmail);
    }

    public TransactionManageResponse updateManagedTransaction(Long id, Long contractId, java.math.BigDecimal amount, String type, String adminEmail) {
        String sql = "SELECT * FROM admin_management.update_transaction(?, ?, ?, ?, ?)";
        return jdbc.queryForObject(sql, (rs, rowNum) -> TransactionManageResponse.builder()
                .id(rs.getLong("id"))
                .contractId(rs.getLong("contract_id"))
                .amount(rs.getBigDecimal("amount"))
                .type(rs.getString("type"))
                .createdAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null)
                .build(), id, contractId, amount, type, adminEmail);
    }

    public void deleteManagedTransaction(Long id, String adminEmail) {
        String sql = "CALL admin_management.delete_transaction(?, ?)";
        jdbc.update(sql, id, adminEmail);
    }
}
