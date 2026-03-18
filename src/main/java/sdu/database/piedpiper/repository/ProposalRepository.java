package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.Proposal;

import java.math.BigDecimal;
import java.util.List;

@Repository
public class ProposalRepository {

    private static final Logger log = LoggerFactory.getLogger(ProposalRepository.class);
    private final JdbcTemplate jdbc;

    public ProposalRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<Proposal> PROPOSAL_MAPPER = (rs, rowNum) -> {
        Proposal p = new Proposal();
        p.setId(rs.getLong("id"));
        p.setJobId(rs.getLong("job_id"));
        p.setFreelancerId(rs.getLong("freelancer_id"));
        p.setBidAmount(rs.getBigDecimal("bid_amount"));
        p.setCoverLetter(rs.getString("cover_letter"));
        p.setStatus(rs.getString("status"));
        return p;
    };

    public void submitProposal(Long jobId, Long freelancerId, BigDecimal bidAmount, String coverLetter) {
        log.debug("Calling submit_proposal for job {} from freelancer {}", jobId, freelancerId);
        String sql = "CALL job_market.submit_proposal(?, ?, ?, ?)";
        jdbc.update(sql, jobId, freelancerId, bidAmount, coverLetter);
    }

    public List<Proposal> findByJobId(Long jobId) {
        String sql = "SELECT * FROM proposals WHERE job_id = ? ORDER BY created_at DESC";
        return jdbc.query(sql, PROPOSAL_MAPPER, jobId);
    }

    public void acceptProposalAndCreateContract(Long proposalId) {
        log.debug("Calling finalize_proposal_and_create_contract for proposal {}", proposalId);
        String sql = "CALL job_market.finalize_proposal_and_create_contract(?)";
        jdbc.update(sql, proposalId);
    }
}