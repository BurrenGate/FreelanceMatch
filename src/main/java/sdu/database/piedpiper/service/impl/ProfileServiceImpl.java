package sdu.database.piedpiper.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.ProfileDTO;
import sdu.database.piedpiper.dto.UserSkillDTO;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.model.ProfileSkill;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.repository.ProfileSkillRepository;
import sdu.database.piedpiper.security.SecurityUtils;
import sdu.database.piedpiper.service.ProfileService;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class ProfileServiceImpl implements ProfileService {

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private ProfileRepository profileRepository;

    @Autowired
    private ProfileSkillRepository profileSkillRepository;

    @Override
    public ProfileDTO getCurrentUserProfile() {
        String username = SecurityUtils.getCurrentUsername();
        Account account = accountRepository.findByEmail(username);
        if (account == null) {
            return null; // Or throw an exception
        }
        Profile profile = profileRepository.findByAccountId(account.getId()).orElse(null);
        if (profile == null) {
            return null; // Or throw an exception
        }

        List<ProfileSkill> skills = profileSkillRepository.findByProfileId(profile.getId());
        List<String> skillNames = skills.stream().map(s -> s.getSkillId().toString()).collect(Collectors.toList()); // Placeholder

        ProfileDTO dto = new ProfileDTO();
        dto.setId(profile.getId());
        dto.setUsername(account.getEmail());
        dto.setEmail(account.getEmail());
        // dto.setRating(...); // No rating field in Profile
        // dto.setBalance(...); // No balance field in Profile
        dto.setSkills(skillNames);

        return dto;
    }

    @Override
    public void addSkillsToCurrentUser(List<UserSkillDTO> skills) {
        String username = SecurityUtils.getCurrentUsername();
        Account account = accountRepository.findByEmail(username);
        if (account == null) {
            return; // Or throw an exception
        }
        Profile profile = profileRepository.findByAccountId(account.getId()).orElse(null);
        if (profile == null) {
            return; // Or throw an exception
        }

        for (UserSkillDTO skillDTO : skills) {
            ProfileSkill profileSkill = new ProfileSkill();
            profileSkill.setProfileId(profile.getId());
            profileSkill.setSkillId(skillDTO.getSkillId().intValue());
            profileSkill.setSkillLevel(skillDTO.getSkillLevel().toString()); // Assuming skill level is a string
            profileSkillRepository.save(profileSkill);
        }
    }
}
