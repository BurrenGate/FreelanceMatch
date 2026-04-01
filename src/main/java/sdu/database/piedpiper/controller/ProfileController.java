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
}
