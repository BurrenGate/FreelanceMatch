package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.MilestoneDTO;
import sdu.database.piedpiper.dto.response.PaymentSummaryDTO;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public class MilestoneRepository {

    private static final Logger log = LoggerFactory.getLogger(MilestoneRepository.class);
    private final JdbcTemplate jdbc;

    public MilestoneRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<MilestoneDTO> MILESTONE_MAPPER = (rs, rowNum) -> {
        MilestoneDTO dto = new MilestoneDTO();
        dto.setMilestoneId(rs.getLong("milestone_id"));
        dto.setTitle(rs.getString("title"));
        dto.setDescription(rs.getString("description"));
        dto.setAmount(rs.getBigDecimal("amount"));
        dto.setStatus(rs.getString("status"));
        dto.setDueDate(rs.getDate("due_date") != null ? rs.getDate("due_date").toLocalDate() : null);
        dto.setCompletedAt(rs.getTimestamp("completed_at") != null 
            ? rs.getTimestamp("completed_at").toLocalDateTime() 
            : null);
        dto.setPaidAt(rs.getTimestamp("paid_at") != null 
            ? rs.getTimestamp("paid_at").toLocalDateTime() 
            : null);
        dto.setCreatedAt(rs.getTimestamp("created_at") != null 
            ? rs.getTimestamp("created_at").toLocalDateTime() 
            : null);
        return dto;
    };

    private static final RowMapper<PaymentSummaryDTO> PAYMENT_SUMMARY_MAPPER = (rs, rowNum) -> {
        PaymentSummaryDTO dto = new PaymentSummaryDTO();
        dto.setContractId(rs.getLong("contract_id"));
        dto.setTotalAmount(rs.getBigDecimal("total_amount"));
        dto.setPaidAmount(rs.getBigDecimal("paid_amount"));
        dto.setRemainingAmount(rs.getBigDecimal("remaining_amount"));
        dto.setTotalMilestones(rs.getInt("total_milestones"));
        dto.setPendingMilestones(rs.getInt("pending_milestones"));
        dto.setCompletedMilestones(rs.getInt("completed_milestones"));
        dto.setPaidMilestones(rs.getInt("paid_milestones"));
        return dto;
    };

    public Long createMilestone(Long contractId, String title, String description, 
                                BigDecimal amount, LocalDate dueDate) {
        log.debug("Calling create_milestone for contract {}", contractId);
        String sql = "SELECT payment_management.create_milestone(?, ?, ?, ?, ?)";
        return jdbc.queryForObject(sql, Long.class, contractId, title, description, amount, dueDate);
    }

    public String updateMilestoneStatus(Long milestoneId, String status) {
        log.debug("Calling update_milestone_status for milestone {}, status {}", milestoneId, status);
        String sql = "SELECT payment_management.update_milestone_status(?, ?)";
        return jdbc.queryForObject(sql, String.class, milestoneId, status);
    }

    public Long payMilestone(Long milestoneId, Long payerId) {
        log.debug("Calling pay_milestone for milestone {}, payer {}", milestoneId, payerId);
        String sql = "SELECT payment_management.pay_milestone(?, ?)";
        return jdbc.queryForObject(sql, Long.class, milestoneId, payerId);
    }

    public List<MilestoneDTO> getContractMilestones(Long contractId, Long userId) {
        log.debug("Calling get_contract_milestones for contract {}, user {}", contractId, userId);
        String sql = "SELECT * FROM payment_management.get_contract_milestones(?, ?)";
        return jdbc.query(sql, MILESTONE_MAPPER, contractId, userId);
    }

    public Optional<PaymentSummaryDTO> getPaymentSummary(Long contractId, Long userId) {
        log.debug("Calling get_contract_payment_summary for contract {}, user {}", contractId, userId);
        String sql = "SELECT * FROM payment_management.get_contract_payment_summary(?, ?)";
        try {
            PaymentSummaryDTO summary = jdbc.queryForObject(sql, PAYMENT_SUMMARY_MAPPER, contractId, userId);
            return Optional.ofNullable(summary);
        } catch (Exception e) {
            log.warn("Payment summary not found: {}", e.getMessage());
            return Optional.empty();
        }
    }
}
