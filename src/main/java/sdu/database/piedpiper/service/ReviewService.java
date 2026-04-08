package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.model.Review;
import sdu.database.piedpiper.repository.ReviewRepository;

import java.util.List;
import java.util.Optional;

@Service
public class ReviewService {

    private static final Logger log = LoggerFactory.getLogger(ReviewService.class);
    private final ReviewRepository reviewRepository;

    public ReviewService(ReviewRepository reviewRepository) {
        this.reviewRepository = reviewRepository;
    }

    public List<Review> getAllReviews() {
        log.info("Fetching all reviews");
        return reviewRepository.findAll();
    }

    public Optional<Review> getReviewById(Long id) {
        log.info("Fetching review with id: {}", id);
        return reviewRepository.findById(id);
    }

    public List<Review> getReviewsByContractId(Long contractId) {
        log.info("Fetching reviews for contract: {}", contractId);
        return reviewRepository.findByContractId(contractId);
    }

    public List<Review> getReviewsByReviewerId(Long reviewerId) {
        log.info("Fetching reviews by reviewer: {}", reviewerId);
        return reviewRepository.findByReviewerId(reviewerId);
    }

    public Review createReview(Review review) {
        log.info("Creating new review for contract: {}", review.getContractId());
        if (review.getRating() < 1 || review.getRating() > 5) {
            throw new IllegalArgumentException("Rating must be between 1 and 5");
        }
        return reviewRepository.save(review);
    }

    public Review updateReview(Long id, Review review) {
        log.info("Updating review: {}", id);
        Optional<Review> existing = reviewRepository.findById(id);
        if (existing.isPresent()) {
            if (review.getRating() < 1 || review.getRating() > 5) {
                throw new IllegalArgumentException("Rating must be between 1 and 5");
            }
            review.setId(id);
            return reviewRepository.save(review);
        }
        throw new RuntimeException("Review not found with id: " + id);
    }

    public void deleteReview(Long id) {
        log.info("Deleting review: {}", id);
        Optional<Review> existing = reviewRepository.findById(id);
        if (existing.isPresent()) {
            reviewRepository.deleteById(id);
        } else {
            throw new RuntimeException("Review not found with id: " + id);
        }
    }
}
