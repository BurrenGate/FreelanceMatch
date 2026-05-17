package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.FreelancerProfileDTO;
import sdu.database.piedpiper.dto.response.FreelancerReviewDTO;
import sdu.database.piedpiper.dto.response.FreelancerSkillDTO;

import java.util.List;
import java.util.Optional;

@Repository
public class FreelancerProfileRepository {

    private static final Logger log = LoggerFactory.getLogger(FreelancerProfileRepository.class);
    private final JdbcTemplate jdbc;

    public FreelancerProfileRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<FreelancerProfileDTO> FREELANCER_PROFILE_MAPPER = (rs, rowNum) -> {
        FreelancerProfileDTO dto = new FreelancerProfileDTO();
        dto.setProfileId(rs.getLong("profile_id"));
        dto.setAccountId(rs.getLong("account_id"));
        dto.setEmail(rs.getString("email"));
        dto.setFirstName(rs.getString("first_name"));
        dto.setLastName(rs.getString("last_name"));
        dto.setFullName(rs.getString("full_name"));
        dto.setBio(rs.getString("bio"));
        dto.setHourlyRate(rs.getBigDecimal("hourly_rate"));
        dto.setAvatarUrl(rs.getString("avatar_url"));
        dto.setRating(rs.getBigDecimal("rating"));
        dto.setTotalEarnings(rs.getBigDecimal("total_earnings"));
        dto.setCompletedJobs(rs.getInt("completed_jobs"));
        dto.setActiveJobs(rs.getInt("active_jobs"));
        dto.setTotalReviews(rs.getInt("total_reviews"));
        dto.setIsAvailable(rs.getBoolean("is_available"));
        dto.setMemberSince(rs.getTimestamp("member_since") != null 
            ? rs.getTimestamp("member_since").toLocalDateTime() 
            : null);
        dto.setLastLogin(rs.getTimestamp("last_login") != null 
            ? rs.getTimestamp("last_login").toLocalDateTime() 
            : null);
        dto.setAccountStatus(rs.getString("account_status"));
        return dto;
    };

    private static final RowMapper<FreelancerSkillDTO> FREELANCER_SKILL_MAPPER = (rs, rowNum) -> {
        FreelancerSkillDTO dto = new FreelancerSkillDTO();
        dto.setSkillId(rs.getInt("skill_id"));
        dto.setSkillName(rs.getString("skill_name"));
        dto.setSkillCategory(rs.getString("skill_category"));
        dto.setSkillLevel(rs.getString("skill_level"));
        return dto;
    };

    private static final RowMapper<FreelancerReviewDTO> FREELANCER_REVIEW_MAPPER = (rs, rowNum) -> {
        FreelancerReviewDTO dto = new FreelancerReviewDTO();
        dto.setReviewId(rs.getLong("review_id"));
        dto.setContractId(rs.getLong("contract_id"));
        dto.setJobTitle(rs.getString("job_title"));
        dto.setReviewerName(rs.getString("reviewer_name"));
        dto.setRating(rs.getInt("rating"));
        dto.setComment(rs.getString("comment"));
        dto.setReviewDate(rs.getTimestamp("review_date") != null 
            ? rs.getTimestamp("review_date").toLocalDateTime() 
            : null);
        return dto;
    };

    public Optional<FreelancerProfileDTO> getFreelancerProfile(Long freelancerId) {
        log.debug("Calling get_freelancer_profile for freelancer {}", freelancerId);
        String sql = "SELECT * FROM job_market.get_freelancer_profile(?)";
        try {
            FreelancerProfileDTO profile = jdbc.queryForObject(sql, FREELANCER_PROFILE_MAPPER, freelancerId);
            return Optional.ofNullable(profile);
        } catch (Exception e) {
            log.warn("Freelancer profile not found with id: {}", freelancerId);
            return Optional.empty();
        }
    }

    public List<FreelancerSkillDTO> getFreelancerSkills(Long freelancerId) {
        log.debug("Calling get_freelancer_skills for freelancer {}", freelancerId);
        String sql = "SELECT * FROM job_market.get_freelancer_skills(?)";
        return jdbc.query(sql, FREELANCER_SKILL_MAPPER, freelancerId);
    }

    public List<FreelancerReviewDTO> getFreelancerReviews(Long freelancerId, Integer limit) {
        log.debug("Calling get_freelancer_reviews for freelancer {} with limit {}", freelancerId, limit);
        String sql = "SELECT * FROM job_market.get_freelancer_reviews(?, ?)";
        return jdbc.query(sql, FREELANCER_REVIEW_MAPPER, freelancerId, limit);
    }
}
