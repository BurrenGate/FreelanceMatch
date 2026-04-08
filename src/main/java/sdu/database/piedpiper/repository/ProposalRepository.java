package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.Proposal;

import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.util.List;
import java.util.Optional;

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

    public List<Proposal> findAll() {
        String sql = "SELECT * FROM proposals ORDER BY created_at DESC";
        log.debug("Fetching all proposals");
        return jdbc.query(sql, PROPOSAL_MAPPER);
    }

    public Optional<Proposal> findById(Long id) {
        String sql = "SELECT * FROM proposals WHERE id = ?";
        log.debug("Finding proposal by id: {}", id);
        try {
            Proposal proposal = jdbc.queryForObject(sql, PROPOSAL_MAPPER, id);
            return Optional.ofNullable(proposal);
        } catch (Exception e) {
            log.warn("Proposal not found with id: {}", id);
            return Optional.empty();
        }
    }

    public Proposal save(Proposal proposal) {
        String sql = "INSERT INTO proposals (job_id, freelancer_id, bid_amount, cover_letter, status) VALUES (?, ?, ?, ?, ?) RETURNING id";
        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbc.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, new String[]{"id"});
            ps.setLong(1, proposal.getJobId());
            ps.setLong(2, proposal.getFreelancerId());
            ps.setBigDecimal(3, proposal.getBidAmount());
            ps.setString(4, proposal.getCoverLetter());
            ps.setString(5, proposal.getStatus() != null ? proposal.getStatus() : "PENDING");
            return ps;
        }, keyHolder);

        Number key = keyHolder.getKey();
        if (key != null) {
            proposal.setId(key.longValue());
        }
        log.debug("Proposal saved with id: {}", proposal.getId());
        return proposal;
    }

    public Proposal update(Long id, Proposal proposal) {
        String sql = "UPDATE proposals SET job_id = ?, freelancer_id = ?, bid_amount = ?, cover_letter = ?, status = ? WHERE id = ?";
        int rowsAffected = jdbc.update(sql,
                proposal.getJobId(),
                proposal.getFreelancerId(),
                proposal.getBidAmount(),
                proposal.getCoverLetter(),
                proposal.getStatus(),
                id);

        if (rowsAffected > 0) {
            proposal.setId(id);
            log.debug("Proposal {} updated successfully", id);
            return proposal;
        } else {
            throw new RuntimeException("Proposal not found with id: " + id);
        }
    }

    public void deleteById(Long id) {
        String sql = "DELETE FROM proposals WHERE id = ?";
        int rowsAffected = jdbc.update(sql, id);

        if (rowsAffected > 0) {
            log.debug("Proposal {} deleted successfully", id);
        } else {
            throw new RuntimeException("Proposal not found with id: " + id);
        }
    }

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