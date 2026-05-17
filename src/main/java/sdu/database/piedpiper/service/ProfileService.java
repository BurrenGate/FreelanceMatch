package sdu.database.piedpiper.service;

import sdu.database.piedpiper.dto.response.FreelancerDashboardDTO;
import sdu.database.piedpiper.dto.response.ProfileDTO;
import sdu.database.piedpiper.dto.response.UpdateProfileDTO;
import sdu.database.piedpiper.dto.response.UserSkillDTO;

import java.util.List;

public interface ProfileService {
    ProfileDTO getCurrentUserProfile();
    void addSkillsToCurrentUser(List<UserSkillDTO> skills);

    void updateCurrentUserProfile(UpdateProfileDTO dto);

    FreelancerDashboardDTO getFreelancerDashboard();

    java.math.BigDecimal getFreelancerRating(Long profileId);

    java.math.BigDecimal getFreelancerTotalEarnings(Long profileId);

    Boolean isFreelancerAvailable(Long profileId);
}
