package sdu.database.piedpiper.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.response.FreelancerDashboardDTO;
import sdu.database.piedpiper.dto.response.ProfileDTO;
import sdu.database.piedpiper.dto.response.UpdateProfileDTO;
import sdu.database.piedpiper.dto.response.UserSkillDTO;
import sdu.database.piedpiper.service.ProfileService;

import java.util.List;

@RestController
@RequestMapping("/api/profiles")
public class ProfileController {

    @Autowired
    private ProfileService profileService;

    @GetMapping("/me")
    public ResponseEntity<ProfileDTO> getCurrentUserProfile() {
        ProfileDTO profileDTO = profileService.getCurrentUserProfile();
        return ResponseEntity.ok(profileDTO);
    }

    @PutMapping("/me")
    public ResponseEntity<Void> updateCurrentUserProfile(@RequestBody UpdateProfileDTO updateDTO) {
        profileService.updateCurrentUserProfile(updateDTO);
        return ResponseEntity.ok().build();
    }


    @PostMapping("/me/skills")
    public ResponseEntity<Void> addSkillsToCurrentUser(@RequestBody List<UserSkillDTO> skills) {
        profileService.addSkillsToCurrentUser(skills);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/me/dashboard")
    public ResponseEntity<FreelancerDashboardDTO> getFreelancerDashboard() {
        FreelancerDashboardDTO dashboard = profileService.getFreelancerDashboard();
        return ResponseEntity.ok(dashboard);
    }

    @GetMapping("/{profileId}/rating")
    public ResponseEntity<java.math.BigDecimal> getFreelancerRating(@PathVariable Long profileId) {
        java.math.BigDecimal rating = profileService.getFreelancerRating(profileId);
        return ResponseEntity.ok(rating);
    }

    @GetMapping("/{profileId}/earnings")
    public ResponseEntity<java.math.BigDecimal> getFreelancerTotalEarnings(@PathVariable Long profileId) {
        java.math.BigDecimal earnings = profileService.getFreelancerTotalEarnings(profileId);
        return ResponseEntity.ok(earnings);
    }

    @GetMapping("/{profileId}/availability")
    public ResponseEntity<java.util.Map<String, Object>> isFreelancerAvailable(@PathVariable Long profileId) {
        Boolean available = profileService.isFreelancerAvailable(profileId);
        java.util.Map<String, Object> response = new java.util.HashMap<>();
        response.put("profileId", profileId);
        response.put("available", available);
        return ResponseEntity.ok(response);
    }
}
