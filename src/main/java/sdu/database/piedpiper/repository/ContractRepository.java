package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.Contract;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.util.List;
import java.util.Optional;

@Repository
public class ContractRepository {

    private static final Logger log = LoggerFactory.getLogger(ContractRepository.class);
    private final JdbcTemplate jdbc;

    public ContractRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<Contract> CONTRACT_MAPPER = (rs, rowNum) -> {
        Contract c = new Contract();
        c.setId(rs.getLong("id"));
        c.setJobId(rs.getLong("job_id"));
        c.setFreelancerId(rs.getLong("freelancer_id"));
        c.setTotalAmount(rs.getBigDecimal("total_amount"));
        c.setStatus(rs.getString("status"));
        return c;
    };

    public List<Contract> findAll() {
        String sql = "SELECT * FROM contracts ORDER BY id DESC";
        log.debug("Fetching all contracts");
        return jdbc.query(sql, CONTRACT_MAPPER);
    }

    public Optional<Contract> findById(Long id) {
        String sql = "SELECT * FROM contracts WHERE id = ?";
        log.debug("Finding contract by id: {}", id);
        try {
            Contract contract = jdbc.queryForObject(sql, CONTRACT_MAPPER, id);
            return Optional.ofNullable(contract);
        } catch (Exception e) {
            log.warn("Contract not found with id: {}", id);
            return Optional.empty();
        }
    }

    public Contract save(Contract contract) {
        String sql = "INSERT INTO contracts (job_id, freelancer_id, total_amount, status) VALUES (?, ?, ?, ?) RETURNING id";
        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbc.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, new String[]{"id"});
            ps.setLong(1, contract.getJobId());
            ps.setLong(2, contract.getFreelancerId());
            ps.setBigDecimal(3, contract.getTotalAmount());
            ps.setString(4, contract.getStatus() != null ? contract.getStatus() : "PENDING");
            return ps;
        }, keyHolder);

        Number key = keyHolder.getKey();
        if (key != null) {
            contract.setId(key.longValue());
        }
        log.debug("Contract saved with id: {}", contract.getId());
        return contract;
    }

    public Contract update(Long id, Contract contract) {
        String sql = "UPDATE contracts SET job_id = ?, freelancer_id = ?, total_amount = ?, status = ? WHERE id = ?";
        int rowsAffected = jdbc.update(sql,
                contract.getJobId(),
                contract.getFreelancerId(),
                contract.getTotalAmount(),
                contract.getStatus(),
                id);

        if (rowsAffected > 0) {
            contract.setId(id);
            log.debug("Contract {} updated successfully", id);
            return contract;
        } else {
            throw new RuntimeException("Contract not found with id: " + id);
        }
    }

    public void deleteById(Long id) {
        String sql = "DELETE FROM contracts WHERE id = ?";
        int rowsAffected = jdbc.update(sql, id);

        if (rowsAffected > 0) {
            log.debug("Contract {} deleted successfully", id);
        } else {
            throw new RuntimeException("Contract not found with id: " + id);
        }
    }

    public void completeJobAndRate(Long contractId, BigDecimal rating, String feedback) {
        log.debug("Calling complete_job_and_rate for contract {}", contractId);
        String sql = "CALL job_market.complete_job_and_rate(?, ?, ?)";
        jdbc.update(sql, contractId, rating, feedback);
    }

    public List<Contract> findByClientId(Long clientId) {
        String sql = "SELECT c.* FROM contracts c JOIN jobs j ON c.job_id = j.id WHERE j.client_id = ?";
        return jdbc.query(sql, CONTRACT_MAPPER, clientId);
    }

    public List<Contract> findByFreelancerId(Long freelancerId) {
        String sql = "SELECT * FROM contracts WHERE freelancer_id = ?";
        return jdbc.query(sql, CONTRACT_MAPPER, freelancerId);
    }

    public BigDecimal getLastTransactionAmount(Long contractId) {
        log.debug("Calling get_last_transaction_amount for contract {}", contractId);
        String sql = "SELECT job_market.get_last_transaction_amount(?)";
        try {
            return jdbc.queryForObject(sql, BigDecimal.class, contractId);
        } catch (Exception e) {
            log.warn("Error getting last transaction amount for contract {}: {}", contractId, e.getMessage());
            return BigDecimal.ZERO;
        }
    }
}
