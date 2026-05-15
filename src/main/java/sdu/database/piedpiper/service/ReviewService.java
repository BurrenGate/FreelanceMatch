package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.ReviewRequest;
import sdu.database.piedpiper.dto.response.ReviewManageResponse;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.exception.NotFoundException;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.model.Review;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.repository.ReviewRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;
import java.util.Optional;

@Service
public class ReviewService {

    private static final Logger log = LoggerFactory.getLogger(ReviewService.class);
    private final ReviewRepository reviewRepository;
    private final AccountRepository accountRepository;
    private final ProfileRepository profileRepository;

    public ReviewService(ReviewRepository reviewRepository,
                         AccountRepository accountRepository,
                         ProfileRepository profileRepository) {
        this.reviewRepository = reviewRepository;
        this.accountRepository = accountRepository;
        this.profileRepository = profileRepository;
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

    public Review createReview(ReviewRequest request) {
        log.info("Creating new review for contract: {}", request.getContractId());
        if (request.getRating() < 1 || request.getRating() > 5) {
            throw new IllegalArgumentException("Rating must be between 1 and 5");
        }

        Review review = Review.builder()
                .contractId(request.getContractId())
                .reviewerId(getCurrentProfileId())
                .rating(request.getRating())
                .comment(request.getComment())
                .build();

        return reviewRepository.save(review);
    }

    public Review updateReview(Long id, ReviewRequest request) {
        log.info("Updating review: {}", id);
        Optional<Review> existing = reviewRepository.findById(id);
        if (existing.isPresent()) {
            if (request.getRating() < 1 || request.getRating() > 5) {
                throw new IllegalArgumentException("Rating must be between 1 and 5");
            }

            Review review = existing.get();
            if (!review.getReviewerId().equals(getCurrentProfileId())) {
                throw new ForbiddenOperationException("You can only update your own reviews");
            }
            review.setId(id);
            review.setContractId(request.getContractId());
            review.setReviewerId(getCurrentProfileId());
            review.setRating(request.getRating());
            review.setComment(request.getComment());
            return reviewRepository.save(review);
        }
        throw new NotFoundException("Review not found with id: " + id);
    }

    public void deleteReview(Long id) {
        log.info("Deleting review: {}", id);
        Optional<Review> existing = reviewRepository.findById(id);
        if (existing.isPresent()) {
            if (!existing.get().getReviewerId().equals(getCurrentProfileId())) {
                throw new ForbiddenOperationException("You can only delete your own reviews");
            }
            reviewRepository.deleteById(id);
        } else {
            throw new NotFoundException("Review not found with id: " + id);
        }
    }

    private Long getCurrentProfileId() {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }

        Account account = accountRepository.findByEmail(email);
        if (account == null) {
            throw new NotFoundException("Account not found for authenticated user");
        }

        Profile profile = profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found for authenticated user"));

        return profile.getId();
    }

    public List<ReviewManageResponse> getManagedReviews(Long contractId, Long reviewerId) {
        return reviewRepository.getManagedReviews(contractId, reviewerId, getCurrentAdminEmail());
    }

    public ReviewManageResponse getManagedReviewById(Long id) {
        return reviewRepository.getManagedReviewById(id, getCurrentAdminEmail());
    }

    public ReviewManageResponse createManagedReview(Long contractId, Long reviewerId, Integer rating, String comment) {
        return reviewRepository.createManagedReview(contractId, reviewerId, rating, comment, getCurrentAdminEmail());
    }

    public ReviewManageResponse updateManagedReview(Long id, Long contractId, Long reviewerId, Integer rating, String comment) {
        return reviewRepository.updateManagedReview(id, contractId, reviewerId, rating, comment, getCurrentAdminEmail());
    }

    public void deleteManagedReview(Long id) {
        reviewRepository.deleteManagedReview(id, getCurrentAdminEmail());
    }

    private String getCurrentAdminEmail() {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null || email.isBlank()) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        if (!SecurityUtils.isAdmin()) {
            throw new ForbiddenOperationException("Only admins can manage reviews");
        }
        return email;
    }
}
