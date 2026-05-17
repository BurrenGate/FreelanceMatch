package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.ReviewManageResponse;
import sdu.database.piedpiper.model.Review;

import java.util.List;
import java.util.Optional;

@Repository
public class ReviewRepository {

    private static final Logger log = LoggerFactory.getLogger(ReviewRepository.class);
    private final JdbcTemplate jdbc;

    public ReviewRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<Review> REVIEW_MAPPER = (rs, rowNum) -> {
        Review r = new Review();
        r.setId(rs.getLong("id"));
        r.setContractId(rs.getLong("contract_id"));
        r.setReviewerId(rs.getLong("reviewer_id"));
        r.setRating(rs.getInt("rating"));
        r.setComment(rs.getString("comment"));
        return r;
    };

    public List<Review> findAll() {
        String sql = "SELECT * FROM app_management.get_reviews()";
        log.debug("Executing findAll() reviews query");
        return jdbc.query(sql, REVIEW_MAPPER);
    }

    public Optional<Review> findById(Long id) {
        String sql = "SELECT * FROM app_management.get_review_by_id(?)";
        try {
            Review review = jdbc.queryForObject(sql, REVIEW_MAPPER, id);
            return Optional.of(review);
        } catch (Exception e) {
            log.debug("Review not found with id: {}", id);
            return Optional.empty();
        }
    }

    public List<Review> findByContractId(Long contractId) {
        String sql = "SELECT * FROM app_management.get_reviews_by_contract(?)";
        return jdbc.query(sql, REVIEW_MAPPER, contractId);
    }

    public List<Review> findByReviewerId(Long reviewerId) {
        String sql = "SELECT * FROM app_management.get_reviews_by_reviewer(?)";
        return jdbc.query(sql, REVIEW_MAPPER, reviewerId);
    }

    public Review save(Review review) {
        String sql = "CALL app_management.upsert_review(?, ?, ?, ?, ?)";
        jdbc.update(sql, review.getId(), review.getContractId(), review.getReviewerId(), review.getRating(), review.getComment());
        return review;
    }

    public void deleteById(Long id) {
        String sql = "CALL app_management.delete_review(?)";
        int deleted = jdbc.update(sql, id);
        if (deleted > 0) {
            log.info("Review deleted: {}", id);
        } else {
            log.warn("No review found with id: {}", id);
        }
    }

    public List<ReviewManageResponse> getManagedReviews(Long contractId, Long reviewerId, String adminEmail) {
        String sql = "SELECT * FROM admin_management.get_reviews(?, ?, ?)";
        return jdbc.query(sql, (rs, rowNum) -> ReviewManageResponse.builder()
                .id(rs.getLong("id"))
                .contractId(rs.getLong("contract_id"))
                .reviewerId(rs.getLong("reviewer_id"))
                .rating(rs.getInt("rating"))
                .comment(rs.getString("comment"))
                .build(), contractId, reviewerId, adminEmail);
    }

    public ReviewManageResponse getManagedReviewById(Long id, String adminEmail) {
        String sql = "SELECT * FROM admin_management.get_review_by_id(?, ?)";
        return jdbc.queryForObject(sql, (rs, rowNum) -> ReviewManageResponse.builder()
                .id(rs.getLong("id"))
                .contractId(rs.getLong("contract_id"))
                .reviewerId(rs.getLong("reviewer_id"))
                .rating(rs.getInt("rating"))
                .comment(rs.getString("comment"))
                .build(), id, adminEmail);
    }

    public ReviewManageResponse createManagedReview(Long contractId, Long reviewerId, Integer rating, String comment, String adminEmail) {
        String sql = "SELECT * FROM admin_management.create_review(?, ?, ?, ?, ?)";
        return jdbc.queryForObject(sql, (rs, rowNum) -> ReviewManageResponse.builder()
                .id(rs.getLong("id"))
                .contractId(rs.getLong("contract_id"))
                .reviewerId(rs.getLong("reviewer_id"))
                .rating(rs.getInt("rating"))
                .comment(rs.getString("comment"))
                .build(), contractId, reviewerId, rating, comment, adminEmail);
    }

    public ReviewManageResponse updateManagedReview(Long id, Long contractId, Long reviewerId, Integer rating, String comment, String adminEmail) {
        String sql = "SELECT * FROM admin_management.update_review(?, ?, ?, ?, ?, ?)";
        return jdbc.queryForObject(sql, (rs, rowNum) -> ReviewManageResponse.builder()
                .id(rs.getLong("id"))
                .contractId(rs.getLong("contract_id"))
                .reviewerId(rs.getLong("reviewer_id"))
                .rating(rs.getInt("rating"))
                .comment(rs.getString("comment"))
                .build(), id, contractId, reviewerId, rating, comment, adminEmail);
    }

    public void deleteManagedReview(Long id, String adminEmail) {
        String sql = "CALL admin_management.delete_review(?, ?)";
        jdbc.update(sql, id, adminEmail);
    }
}
