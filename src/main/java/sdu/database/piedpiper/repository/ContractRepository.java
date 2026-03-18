package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;

@Repository
public class ContractRepository {

    private static final Logger log = LoggerFactory.getLogger(ContractRepository.class);
    private final JdbcTemplate jdbc;

    public ContractRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public void completeJobAndRate(Long contractId, BigDecimal rating, String feedback) {
        log.debug("Calling complete_job_and_rate for contract {}", contractId);
        String sql = "CALL job_market.complete_job_and_rate(?, ?, ?)";
        jdbc.update(sql, contractId, rating, feedback);
    }
}