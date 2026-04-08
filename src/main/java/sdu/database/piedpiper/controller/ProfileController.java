package sdu.database.piedpiper.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.response.*;
import sdu.database.piedpiper.security.SecurityUtils;
import sdu.database.piedpiper.service.ProfileService;

import java.util.List;

@RestController
@RequestMapping("/api/profiles")
public class ProfileController {

    @Autowired
    private ProfileService profileService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<ProfileDTO>> getCurrentUserProfile() {
        try {
            ProfileDTO profileDTO = profileService.getCurrentUserProfile();
            return ResponseEntity.ok(ApiResponse.ok("Profile retrieved successfully", profileDTO));
        } catch (Exception ex) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to retrieve profile: " + ex.getMessage()));
        }
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<Void>> updateCurrentUserProfile(@RequestBody UpdateProfileDTO updateDTO) {
        try {
            profileService.updateCurrentUserProfile(updateDTO);
            return ResponseEntity.ok(ApiResponse.ok("Profile updated successfully", null));
        } catch (Exception ex) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to update profile: " + ex.getMessage()));
        }
    }

    @PostMapping("/me/skills")
    public ResponseEntity<ApiResponse<Void>> addSkillsToCurrentUser(@RequestBody List<UserSkillDTO> skills) {
        try {
            if (skills == null || skills.isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(ApiResponse.error("Skills list cannot be empty"));
            }
            profileService.addSkillsToCurrentUser(skills);
            return ResponseEntity.ok(ApiResponse.ok("Skills added successfully", null));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(ex.getMessage()));
        } catch (Exception ex) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to add skills: " + ex.getMessage()));
        }
    }

    @GetMapping("/me/dashboard")
    public ResponseEntity<ApiResponse<FreelancerDashboardDTO>> getFreelancerDashboard() {
        try {
            if (!SecurityUtils.isFreelancer()) {
                return ResponseEntity.status(403)
                        .body(ApiResponse.error("Insufficient permissions. Only freelancers can access the dashboard."));
            }
            FreelancerDashboardDTO dashboard = profileService.getFreelancerDashboard();
            return ResponseEntity.ok(ApiResponse.ok("Dashboard retrieved successfully", dashboard));
        } catch (Exception ex) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error("Failed to retrieve dashboard: " + ex.getMessage()));
        }
    }

    @GetMapping("/{profileId}/rating")
    public ResponseEntity<ApiResponse<java.util.Map<String, Object>>> getFreelancerRating(@PathVariable Long profileId) {
        try {
            java.math.BigDecimal rating = profileService.getFreelancerRating(profileId);
            java.util.Map<String, Object> result = new java.util.HashMap<>();
            result.put("profileId", profileId);
            result.put("rating", rating);
            return ResponseEntity.ok(ApiResponse.ok("Rating retrieved successfully", result));
        } catch (Exception ex) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/{profileId}/earnings")
    public ResponseEntity<ApiResponse<java.util.Map<String, Object>>> getFreelancerTotalEarnings(@PathVariable Long profileId) {
        try {
            java.math.BigDecimal earnings = profileService.getFreelancerTotalEarnings(profileId);
            java.util.Map<String, Object> result = new java.util.HashMap<>();
            result.put("profileId", profileId);
            result.put("totalEarnings", earnings);
            return ResponseEntity.ok(ApiResponse.ok("Earnings retrieved successfully", result));
        } catch (Exception ex) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/{profileId}/availability")
    public ResponseEntity<ApiResponse<java.util.Map<String, Object>>> isFreelancerAvailable(@PathVariable Long profileId) {
        try {
            Boolean available = profileService.isFreelancerAvailable(profileId);
            java.util.Map<String, Object> response = new java.util.HashMap<>();
            response.put("profileId", profileId);
            response.put("available", available);
            return ResponseEntity.ok(ApiResponse.ok("Availability retrieved successfully", response));
        } catch (Exception ex) {
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(ex.getMessage()));
        }
    }
}
