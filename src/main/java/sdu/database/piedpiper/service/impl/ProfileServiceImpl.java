package sdu.database.piedpiper.service.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.response.*;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.DashboardRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.repository.ProfileSkillRepository;
import sdu.database.piedpiper.security.SecurityUtils;
import sdu.database.piedpiper.service.ProfileService;

import java.util.List;

@Service
public class ProfileServiceImpl implements ProfileService {

    private final AccountRepository accountRepository;
    private final ProfileRepository profileRepository;
    private final ProfileSkillRepository profileSkillRepository;
    private final DashboardRepository dashboardRepository; // Добавляем репозиторий дашборда

    // Внедрение зависимостей через конструктор
    public ProfileServiceImpl(AccountRepository accountRepository,
                              ProfileRepository profileRepository,
                              ProfileSkillRepository profileSkillRepository,
                              DashboardRepository dashboardRepository) {
        this.accountRepository = accountRepository;
        this.profileRepository = profileRepository;
        this.profileSkillRepository = profileSkillRepository;
        this.dashboardRepository = dashboardRepository;
    }

    @Override
    public ProfileDTO getCurrentUserProfile() {
        String username = SecurityUtils.getCurrentUsername();

        ProfileDTO profileDTO = profileRepository.getFullProfileByEmail(username)
                .orElseThrow(() -> new RuntimeException("Profile not found for user: " + username));

        // Если профиль существует, подтягиваем его детальные навыки
        if (profileDTO.getProfileId() != null) {
            List<ProfileSkillDetailedDTO> skills = profileSkillRepository.getDetailedSkillsByProfileId(profileDTO.getProfileId());
            profileDTO.setSkills(skills);
        }

        return profileDTO;
    }

    @Override
    public void addSkillsToCurrentUser(List<UserSkillDTO> skills) {
        String email = SecurityUtils.getCurrentUsername();

        if (email == null) {
            throw new RuntimeException("User is not authenticated");
        }

        // Передаем всю работу базе данных
        profileSkillRepository.addSkillsToProfile(email, skills);
    }

    @Override
    public void updateCurrentUserProfile(UpdateProfileDTO dto) {
        String username = SecurityUtils.getCurrentUsername();

        if (username == null) {
            throw new RuntimeException("User is not authenticated");
        }

        // Передаем данные в БД. Вся логика поиска и обновления скрыта в PL/SQL
        profileRepository.updateProfile(username, dto);
    }

    @Override
    public FreelancerDashboardDTO getFreelancerDashboard() {
        String username = SecurityUtils.getCurrentUsername();

        if (username == null) {
            throw new RuntimeException("User is not authenticated");
        }

        // 1. Получаем профиль пользователя, чтобы достать его profileId
        ProfileDTO profileDTO = profileRepository.getFullProfileByEmail(username)
                .orElseThrow(() -> new RuntimeException("Profile not found for user: " + username));

        Long profileId = profileDTO.getProfileId();

        // 2. Вызываем PL/pgSQL функцию через DashboardRepository, передавая profileId
        try {
            return dashboardRepository.getDashboardByFreelancerId(profileId);
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }

    @Override
    public java.math.BigDecimal getFreelancerRating(Long profileId) {
        return profileRepository.getFreelancerRating(profileId);
    }

    @Override
    public java.math.BigDecimal getFreelancerTotalEarnings(Long profileId) {
        return profileRepository.getFreelancerTotalEarnings(profileId);
    }

    @Override
    public Boolean isFreelancerAvailable(Long profileId) {
        return profileRepository.isFreelancerAvailable(profileId);
    }
}