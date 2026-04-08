package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.model.Review;
import sdu.database.piedpiper.security.SecurityUtils;
import sdu.database.piedpiper.service.ReviewService;

import java.util.List;

@RestController
@RequestMapping("/api/reviews")
public class ReviewController {

    private static final Logger log = LoggerFactory.getLogger(ReviewController.class);
    private final ReviewService reviewService;

    public ReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Review>>> getAllReviews() {
        try {
            log.debug("GET /api/reviews");
            List<Review> reviews = reviewService.getAllReviews();
            return ResponseEntity.ok(ApiResponse.ok(
                    reviews.isEmpty() ? "No reviews found" : "Retrieved " + reviews.size() + " review(s)",
                    reviews
            ));
        } catch (Exception ex) {
            log.error("Error getting all reviews: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Review>> getReviewById(@PathVariable Long id) {
        try {
            log.debug("GET /api/reviews/{}", id);
            return reviewService.getReviewById(id)
                    .map(review -> ResponseEntity.ok(ApiResponse.ok("Review retrieved successfully", review)))
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception ex) {
            log.error("Error getting review: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/contract/{contractId}")
    public ResponseEntity<ApiResponse<List<Review>>> getReviewsByContractId(@PathVariable Long contractId) {
        try {
            log.debug("GET /api/reviews/contract/{}", contractId);
            List<Review> reviews = reviewService.getReviewsByContractId(contractId);
            return ResponseEntity.ok(ApiResponse.ok(
                    reviews.isEmpty() ? "No reviews found for contract" : "Retrieved " + reviews.size() + " review(s)",
                    reviews
            ));
        } catch (Exception ex) {
            log.error("Error getting reviews by contract: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/reviewer/{reviewerId}")
    public ResponseEntity<ApiResponse<List<Review>>> getReviewsByReviewerId(@PathVariable Long reviewerId) {
        try {
            log.debug("GET /api/reviews/reviewer/{}", reviewerId);
            List<Review> reviews = reviewService.getReviewsByReviewerId(reviewerId);
            return ResponseEntity.ok(ApiResponse.ok(
                    reviews.isEmpty() ? "No reviews found from reviewer" : "Retrieved " + reviews.size() + " review(s)",
                    reviews
            ));
        } catch (Exception ex) {
            log.error("Error getting reviews by reviewer: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Review>> createReview(@RequestBody Review review) {
        try {
            log.debug("POST /api/reviews");
            if (!SecurityUtils.hasAnyRole(1, 2)) {  // 1 = CLIENT, 2 = FREELANCER
                return ResponseEntity.status(403)
                        .body(ApiResponse.error("Insufficient permissions. Only clients and freelancers can create reviews."));
            }
            if (review.getContractId() == null || review.getReviewerId() == null) {
                return ResponseEntity.badRequest().body(ApiResponse.error("Contract ID and Reviewer ID are required"));
            }
            if (review.getRating() == null || review.getRating() < 1 || review.getRating() > 5) {
                return ResponseEntity.badRequest().body(ApiResponse.error("Rating must be between 1 and 5"));
            }
            Review created = reviewService.createReview(review);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Review created successfully", created));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        } catch (Exception ex) {
            log.error("Error creating review: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Review>> updateReview(@PathVariable Long id, @RequestBody Review review) {
        try {
            log.debug("PUT /api/reviews/{}", id);
            if (review.getRating() == null || review.getRating() < 1 || review.getRating() > 5) {
                return ResponseEntity.badRequest().body(ApiResponse.error("Rating must be between 1 and 5"));
            }
            Review updated = reviewService.updateReview(id, review);
            return ResponseEntity.ok(ApiResponse.ok("Review updated successfully", updated));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        } catch (Exception ex) {
            log.error("Error updating review: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteReview(@PathVariable Long id) {
        try {
            log.debug("DELETE /api/reviews/{}", id);
            reviewService.deleteReview(id);
            return ResponseEntity.ok(ApiResponse.ok("Review deleted successfully", null));
        } catch (Exception ex) {
            log.error("Error deleting review: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }
}
