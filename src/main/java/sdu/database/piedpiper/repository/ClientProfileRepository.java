package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.ClientJobDTO;
import sdu.database.piedpiper.dto.response.ClientProfileDTO;
import sdu.database.piedpiper.dto.response.ClientReviewDTO;

import java.util.List;

@Repository
public class ClientProfileRepository {

    private static final Logger log = LoggerFactory.getLogger(ClientProfileRepository.class);
    private final JdbcTemplate jdbc;

    public ClientProfileRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<ClientProfileDTO> PROFILE_MAPPER = (rs, rowNum) -> {
        ClientProfileDTO dto = new ClientProfileDTO();
        dto.setProfileId(rs.getLong("profile_id"));
        dto.setAccountId(rs.getLong("account_id"));
        dto.setEmail(rs.getString("email"));
        dto.setFirstName(rs.getString("first_name"));
        dto.setLastName(rs.getString("last_name"));
        dto.setFullName(rs.getString("first_name") + " " + rs.getString("last_name"));
        dto.setBio(rs.getString("bio"));
        dto.setAvatarUrl(rs.getString("avatar_url"));
        dto.setTotalSpent(rs.getBigDecimal("total_spent"));
        dto.setPostedJobs(rs.getInt("posted_jobs"));
        dto.setActiveJobs(rs.getInt("active_jobs"));
        dto.setCompletedJobs(rs.getInt("completed_jobs"));
        dto.setTotalReviewsGiven(rs.getInt("total_reviews_given"));
        dto.setAverageRatingGiven(rs.getBigDecimal("average_rating_given"));
        dto.setMemberSince(rs.getTimestamp("member_since") != null 
            ? rs.getTimestamp("member_since").toLocalDateTime() 
            : null);
        dto.setLastLogin(rs.getTimestamp("last_login") != null 
            ? rs.getTimestamp("last_login").toLocalDateTime() 
            : null);
        dto.setAccountStatus(rs.getString("account_status"));
        return dto;
    };

    private static final RowMapper<ClientJobDTO> JOB_MAPPER = (rs, rowNum) -> {
        ClientJobDTO dto = new ClientJobDTO();
        dto.setJobId(rs.getLong("job_id"));
        dto.setTitle(rs.getString("title"));
        dto.setDescription(rs.getString("description"));
        dto.setBudget(rs.getBigDecimal("budget"));
        dto.setStatus(rs.getString("status"));
        dto.setProposalsCount(rs.getInt("proposals_count"));
        dto.setCreatedAt(rs.getTimestamp("created_at") != null 
            ? rs.getTimestamp("created_at").toLocalDateTime() 
            : null);
        return dto;
    };

    private static final RowMapper<ClientReviewDTO> REVIEW_MAPPER = (rs, rowNum) -> {
        ClientReviewDTO dto = new ClientReviewDTO();
        dto.setReviewId(rs.getLong("review_id"));
        dto.setContractId(rs.getLong("contract_id"));
        dto.setJobTitle(rs.getString("job_title"));
        dto.setFreelancerName(rs.getString("freelancer_name"));
        dto.setRating(rs.getInt("rating"));
        dto.setComment(rs.getString("comment"));
        dto.setCreatedAt(rs.getTimestamp("created_at") != null 
            ? rs.getTimestamp("created_at").toLocalDateTime() 
            : null);
        return dto;
    };

    public ClientProfileDTO getClientProfile(Long clientId) {
        log.debug("Calling get_client_profile for client {}", clientId);
        String sql = "SELECT * FROM job_market.get_client_profile(?)";
        try {
            List<ClientProfileDTO> results = jdbc.query(sql, PROFILE_MAPPER, clientId);
            return results.isEmpty() ? null : results.get(0);
        } catch (Exception e) {
            log.error("Error calling get_client_profile for clientId {}: {}", clientId, e.getMessage(), e);
            throw e;
        }
    }

    public List<ClientJobDTO> getClientJobs(Long clientId, Integer limit) {
        log.debug("Calling get_client_jobs for client {}, limit: {}", clientId, limit);
        String sql = "SELECT * FROM job_market.get_client_jobs(?, ?)";
        return jdbc.query(sql, JOB_MAPPER, clientId, limit);
    }

    public List<ClientReviewDTO> getClientReviews(Long clientId, Integer limit) {
        log.debug("Calling get_client_reviews_given for client {}, limit: {}", clientId, limit);
        String sql = "SELECT * FROM job_market.get_client_reviews_given(?, ?)";
        return jdbc.query(sql, REVIEW_MAPPER, clientId, limit);
    }
}
