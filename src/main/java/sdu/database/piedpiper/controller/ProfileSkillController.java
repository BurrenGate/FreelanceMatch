package sdu.database.piedpiper.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.response.ProfileSkillDetailedDTO;
import sdu.database.piedpiper.dto.response.UserSkillDTO;
import sdu.database.piedpiper.service.ProfileSkillService;

import java.util.List;

@RestController
@RequestMapping("/api/skills")
public class ProfileSkillController {

    private final ProfileSkillService profileSkillService;

    public ProfileSkillController(ProfileSkillService profileSkillService) {
        this.profileSkillService = profileSkillService;
    }

    // Получить все существующие навыки из справочника
    @GetMapping
    public ResponseEntity<List<ProfileSkillDetailedDTO>> getAllAvailableSkills() {
        List<ProfileSkillDetailedDTO> skills = profileSkillService.getAllAvailableSkills();
        return ResponseEntity.ok(skills);
    }

    // Получить навыки, которые профиль еще НЕ добавил себе (доступные для добавления)
    @GetMapping("/profile/{profileId}/available")
    public ResponseEntity<List<ProfileSkillDetailedDTO>> getAvailableSkillsForProfile(@PathVariable Long profileId) {
        List<ProfileSkillDetailedDTO> skills = profileSkillService.getAvailableSkillsForProfile(profileId);
        return ResponseEntity.ok(skills);
    }

    // Получить уже добавленные навыки профиля
    @GetMapping("/profile/{profileId}")
    public ResponseEntity<List<ProfileSkillDetailedDTO>> getProfileSkills(@PathVariable Long profileId) {
        List<ProfileSkillDetailedDTO> skills = profileSkillService.getProfileSkills(profileId);
        return ResponseEntity.ok(skills);
    }

    // Добавить новые навыки профилю
    @PostMapping("/profile/add")
    public ResponseEntity<Void> addSkillsToProfile(
            @RequestParam String email,
            @RequestBody List<UserSkillDTO> skills) {
        
        profileSkillService.addSkillsToProfile(email, skills);
        return ResponseEntity.ok().build(); // Возвращаем 200 OK без тела ответа
    }
}