package sdu.database.piedpiper.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.ProfileDTO;
import sdu.database.piedpiper.dto.UserSkillDTO;
import sdu.database.piedpiper.service.ProfileService;

import java.util.List;

@RestController
@RequestMapping("/api/profiles")
public class ProfileController {

    @Autowired
    private ProfileService profileService;

    @GetMapping("/me")
    public ProfileDTO getCurrentUserProfile() {
        return profileService.getCurrentUserProfile();
    }

    @PostMapping("/me/skills")
    public void addSkillsToCurrentUser(@RequestBody List<UserSkillDTO> skills) {
        profileService.addSkillsToCurrentUser(skills);
    }
}
