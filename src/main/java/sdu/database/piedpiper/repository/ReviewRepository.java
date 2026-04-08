package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
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
        String sql = "SELECT id, contract_id, reviewer_id, rating, comment FROM reviews ORDER BY id DESC";
        log.debug("Executing findAll() reviews query");
        return jdbc.query(sql, REVIEW_MAPPER);
    }

    public Optional<Review> findById(Long id) {
        String sql = "SELECT id, contract_id, reviewer_id, rating, comment FROM reviews WHERE id = ?";
        try {
            Review review = jdbc.queryForObject(sql, REVIEW_MAPPER, id);
            return Optional.of(review);
        } catch (Exception e) {
            log.debug("Review not found with id: {}", id);
            return Optional.empty();
        }
    }

    public List<Review> findByContractId(Long contractId) {
        String sql = "SELECT id, contract_id, reviewer_id, rating, comment FROM reviews WHERE contract_id = ? ORDER BY id DESC";
        return jdbc.query(sql, REVIEW_MAPPER, contractId);
    }

    public List<Review> findByReviewerId(Long reviewerId) {
        String sql = "SELECT id, contract_id, reviewer_id, rating, comment FROM reviews WHERE reviewer_id = ? ORDER BY id DESC";
        return jdbc.query(sql, REVIEW_MAPPER, reviewerId);
    }

    public Review save(Review review) {
        if (review.getId() != null) {
            String sql = "UPDATE reviews SET contract_id = ?, reviewer_id = ?, rating = ?, comment = ? WHERE id = ?";
            jdbc.update(sql, review.getContractId(), review.getReviewerId(), review.getRating(), review.getComment(), review.getId());
            log.info("Review updated: {}", review.getId());
        } else {
            String sql = "INSERT INTO reviews (contract_id, reviewer_id, rating, comment) VALUES (?, ?, ?, ?)";
            jdbc.update(sql, review.getContractId(), review.getReviewerId(), review.getRating(), review.getComment());
            log.info("Review created for contract: {}", review.getContractId());
        }
        return review;
    }

    public void deleteById(Long id) {
        String sql = "DELETE FROM reviews WHERE id = ?";
        int deleted = jdbc.update(sql, id);
        if (deleted > 0) {
            log.info("Review deleted: {}", id);
        } else {
            log.warn("No review found with id: {}", id);
        }
    }
}
