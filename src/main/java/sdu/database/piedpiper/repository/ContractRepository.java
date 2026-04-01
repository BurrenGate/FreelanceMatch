package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.Contract;

import java.math.BigDecimal;
import java.util.List;

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
}
