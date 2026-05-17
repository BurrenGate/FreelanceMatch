package sdu.database.piedpiper.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.ReviewUpsertRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.ReviewManageResponse;
import sdu.database.piedpiper.service.ReviewService;

import java.util.List;

@RestController
@RequestMapping("/api/reviews/manage")
public class AdminReviewController {

    private final ReviewService reviewService;

    public AdminReviewController(ReviewService reviewService) {
        this.reviewService = reviewService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ReviewManageResponse>>> getManagedReviews(
            @RequestParam(required = false) Long contractId,
            @RequestParam(required = false) Long reviewerId
    ) {
        List<ReviewManageResponse> reviews = reviewService.getManagedReviews(contractId, reviewerId);
        return ResponseEntity.ok(ApiResponse.ok("Reviews retrieved successfully", reviews));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ReviewManageResponse>> getManagedReviewById(@PathVariable Long id) {
        ReviewManageResponse review = reviewService.getManagedReviewById(id);
        return ResponseEntity.ok(ApiResponse.ok("Review retrieved successfully", review));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ReviewManageResponse>> createManagedReview(
            @Valid @RequestBody ReviewUpsertRequest request
    ) {
        ReviewManageResponse created = reviewService.createManagedReview(
                request.getContractId(),
                request.getReviewerId(),
                request.getRating(),
                request.getComment()
        );
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Review created successfully", created));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ReviewManageResponse>> updateManagedReview(
            @PathVariable Long id,
            @Valid @RequestBody ReviewUpsertRequest request
    ) {
        ReviewManageResponse updated = reviewService.updateManagedReview(
                id,
                request.getContractId(),
                request.getReviewerId(),
                request.getRating(),
                request.getComment()
        );
        return ResponseEntity.ok(ApiResponse.ok("Review updated successfully", updated));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteManagedReview(@PathVariable Long id) {
        reviewService.deleteManagedReview(id);
        return ResponseEntity.ok(ApiResponse.ok("Review deleted successfully", null));
    }
}
