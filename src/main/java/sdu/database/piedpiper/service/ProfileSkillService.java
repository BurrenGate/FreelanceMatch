package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.response.ProfileSkillDetailedDTO;
import sdu.database.piedpiper.dto.response.ProfileSkillResponse;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.dto.response.UserSkillDTO;
import sdu.database.piedpiper.repository.ProfileSkillRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;

@Service
public class ProfileSkillService {

    private static final Logger log = LoggerFactory.getLogger(ProfileSkillService.class);
    private final ProfileSkillRepository profileSkillRepository;

    public ProfileSkillService(ProfileSkillRepository profileSkillRepository) {
        this.profileSkillRepository = profileSkillRepository;
    }

    public List<ProfileSkillDetailedDTO> getAllAvailableSkills() {
        log.info("Fetching all available skills from the dictionary");
        return profileSkillRepository.getAllAvailableSkills();
    }

    public List<ProfileSkillDetailedDTO> getAvailableSkillsForProfile(Long profileId) {
        log.info("Fetching available skills to add for Profile ID: {}", profileId);
        return profileSkillRepository.getAvailableSkillsForProfile(profileId);
    }

    public List<ProfileSkillDetailedDTO> getProfileSkills(Long profileId) {
        log.info("Fetching already assigned detailed skills for Profile ID: {}", profileId);
        return profileSkillRepository.getDetailedSkillsByProfileId(profileId);
    }

    public void addSkillsToProfile(String email, List<UserSkillDTO> skills) {
        log.info("Adding {} skills to profile associated with email: {}", skills.size(), email);
        profileSkillRepository.addSkillsToProfile(email, skills);
    }

    public List<ProfileSkillResponse> getMySkills() {
        return profileSkillRepository.getMySkills(getCurrentUserEmail());
    }

    public List<ProfileSkillResponse> getMyAvailableSkills() {
        return profileSkillRepository.getMyAvailableSkills(getCurrentUserEmail());
    }

    public void upsertMySkill(Integer skillId, String skillLevel) {
        profileSkillRepository.upsertMySkill(getCurrentUserEmail(), skillId, skillLevel);
    }

    public void deleteMySkill(Integer skillId) {
        profileSkillRepository.deleteMySkill(getCurrentUserEmail(), skillId);
    }

    private String getCurrentUserEmail() {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null || email.isBlank()) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        return email;
    }
}
