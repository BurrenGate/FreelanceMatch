package sdu.database.piedpiper.service;

import sdu.database.piedpiper.dto.ProfileDTO;
import sdu.database.piedpiper.dto.UserSkillDTO;

import java.util.List;

public interface ProfileService {
    ProfileDTO getCurrentUserProfile();
    void addSkillsToCurrentUser(List<UserSkillDTO> skills);
}
