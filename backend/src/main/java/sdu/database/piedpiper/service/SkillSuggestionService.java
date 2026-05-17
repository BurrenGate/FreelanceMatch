package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.ReviewSkillSuggestionRequest;
import sdu.database.piedpiper.dto.request.SuggestSkillRequest;
import sdu.database.piedpiper.dto.response.MySkillSuggestionDTO;
import sdu.database.piedpiper.dto.response.SkillSuggestionDTO;
import sdu.database.piedpiper.dto.response.SkillSuggestionStatsDTO;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.exception.NotFoundException;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.repository.SkillSuggestionRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;
import java.util.Map;

@Service
public class SkillSuggestionService {

    private static final Logger log = LoggerFactory.getLogger(SkillSuggestionService.class);
    private final SkillSuggestionRepository skillSuggestionRepository;
    private final AccountRepository accountRepository;
    private final ProfileRepository profileRepository;

    public SkillSuggestionService(SkillSuggestionRepository skillSuggestionRepository,
                                  AccountRepository accountRepository,
                                  ProfileRepository profileRepository) {
        this.skillSuggestionRepository = skillSuggestionRepository;
        this.accountRepository = accountRepository;
        this.profileRepository = profileRepository;
    }

    public Map<String, Object> suggestSkill(SuggestSkillRequest request) {
        log.info("User suggesting new skill: {}", request.getName());
        
        // Only clients and freelancers can suggest skills
        if (!SecurityUtils.hasAnyRole(1, 2)) {
            throw new ForbiddenOperationException("Only clients and freelancers can suggest skills");
        }
        
        Profile currentProfile = getCurrentProfile();
        return skillSuggestionRepository.suggestSkill(
                request.getName(),
                request.getCategory(),
                currentProfile.getId()
        );
    }

    public List<SkillSuggestionDTO> getAllSkillSuggestions(String status) {
        log.info("Admin fetching skill suggestions with status: {}", status);
        
        if (!SecurityUtils.isAdmin()) {
            throw new ForbiddenOperationException("Only administrators can view all skill suggestions");
        }
        
        Profile currentProfile = getCurrentProfile();
        return skillSuggestionRepository.getSkillSuggestions(currentProfile.getId(), status);
    }

    public List<MySkillSuggestionDTO> getMySkillSuggestions() {
        log.info("User fetching their own skill suggestions");
        
        Profile currentProfile = getCurrentProfile();
        return skillSuggestionRepository.getMySkillSuggestions(currentProfile.getId());
    }

    public Map<String, Object> approveSkillSuggestion(Long suggestionId, ReviewSkillSuggestionRequest request) {
        log.info("Admin approving skill suggestion: {}", suggestionId);
        
        if (!SecurityUtils.isAdmin()) {
            throw new ForbiddenOperationException("Only administrators can approve skill suggestions");
        }
        
        Profile currentProfile = getCurrentProfile();
        return skillSuggestionRepository.approveSkillSuggestion(
                suggestionId,
                currentProfile.getId(),
                request != null ? request.getAdminComment() : null
        );
    }

    public Map<String, Object> rejectSkillSuggestion(Long suggestionId, ReviewSkillSuggestionRequest request) {
        log.info("Admin rejecting skill suggestion: {}", suggestionId);
        
        if (!SecurityUtils.isAdmin()) {
            throw new ForbiddenOperationException("Only administrators can reject skill suggestions");
        }
        
        if (request == null || request.getAdminComment() == null || request.getAdminComment().trim().isEmpty()) {
            throw new IllegalArgumentException("Admin comment is required when rejecting a suggestion");
        }
        
        Profile currentProfile = getCurrentProfile();
        return skillSuggestionRepository.rejectSkillSuggestion(
                suggestionId,
                currentProfile.getId(),
                request.getAdminComment()
        );
    }

    public SkillSuggestionStatsDTO getSuggestionStatistics() {
        log.info("Admin fetching skill suggestion statistics");
        
        if (!SecurityUtils.isAdmin()) {
            throw new ForbiddenOperationException("Only administrators can view statistics");
        }
        
        Profile currentProfile = getCurrentProfile();
        return skillSuggestionRepository.getSuggestionStatistics(currentProfile.getId());
    }

    private Profile getCurrentProfile() {
        String username = SecurityUtils.getCurrentUsername();
        if (username == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        Account account = accountRepository.findByEmail(username);
        if (account == null) {
            throw new NotFoundException("Account not found for authenticated user");
        }
        return profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found for authenticated user"));
    }
}
