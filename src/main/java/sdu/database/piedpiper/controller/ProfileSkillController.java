package sdu.database.piedpiper.controller;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.UpsertProfileSkillRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.ProfileSkillResponse;
import sdu.database.piedpiper.service.ProfileSkillService;

import java.util.List;

@RestController
@RequestMapping("/api/profile-skills/me")
public class ProfileSkillController {

    private final ProfileSkillService profileSkillService;

    public ProfileSkillController(ProfileSkillService profileSkillService) {
        this.profileSkillService = profileSkillService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<ProfileSkillResponse>>> getMySkills() {
        List<ProfileSkillResponse> data = profileSkillService.getMySkills();
        return ResponseEntity.ok(ApiResponse.ok("Profile skills retrieved successfully", data));
    }

    @GetMapping("/available")
    public ResponseEntity<ApiResponse<List<ProfileSkillResponse>>> getMyAvailableSkills() {
        List<ProfileSkillResponse> data = profileSkillService.getMyAvailableSkills();
        return ResponseEntity.ok(ApiResponse.ok("Available skills retrieved successfully", data));
    }

    @PutMapping
    public ResponseEntity<ApiResponse<Void>> upsertMySkill(@Valid @RequestBody UpsertProfileSkillRequest request) {
        profileSkillService.upsertMySkill(request.getSkillId(), request.getSkillLevel());
        return ResponseEntity.ok(ApiResponse.ok("Profile skill saved successfully", null));
    }

    @DeleteMapping("/{skillId}")
    public ResponseEntity<ApiResponse<Void>> deleteMySkill(@PathVariable Integer skillId) {
        profileSkillService.deleteMySkill(skillId);
        return ResponseEntity.ok(ApiResponse.ok("Profile skill removed successfully", null));
    }
}
