package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.response.SkillResponse;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.model.Skill;
import sdu.database.piedpiper.repository.SkillRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;
import java.util.Optional;

@Service
public class SkillService {

    private static final Logger log = LoggerFactory.getLogger(SkillService.class);
    private final SkillRepository skillRepository;

    public SkillService(SkillRepository skillRepository) {
        this.skillRepository = skillRepository;
    }

    public List<Skill> getAllSkills() {
        log.info("Fetching all skills");
        return skillRepository.findAll();
    }

    public Optional<Skill> getSkillById(Integer id) {
        log.info("Fetching skill with id: {}", id);
        return skillRepository.findById(id);
    }

    public Skill createSkill(Skill skill) {
        log.info("Creating new skill: {}", skill.getName());
        return skillRepository.save(skill);
    }

    public Skill updateSkill(Integer id, Skill skill) {
        log.info("Updating skill: {}", id);
        Optional<Skill> existing = skillRepository.findById(id);
        if (existing.isPresent()) {
            skill.setId(id);
            return skillRepository.save(skill);
        }
        throw new RuntimeException("Skill not found with id: " + id);
    }

    public void deleteSkill(Integer id) {
        log.info("Deleting skill: {}", id);
        Optional<Skill> existing = skillRepository.findById(id);
        if (existing.isPresent()) {
            skillRepository.deleteById(id);
        } else {
            throw new RuntimeException("Skill not found with id: " + id);
        }
    }

    public List<Skill> getSkillsByCategory(String category) {
        log.info("Fetching skills by category: {}", category);
        return skillRepository.findByCategory(category);
    }

    public List<SkillResponse> getManagedSkills(String category) {
        return skillRepository.getManagedSkills(category, getCurrentAdminEmail());
    }

    public SkillResponse getManagedSkillById(Integer id) {
        return skillRepository.getManagedSkillById(id, getCurrentAdminEmail());
    }

    public SkillResponse createManagedSkill(String name, String category) {
        return skillRepository.createManagedSkill(name, category, getCurrentAdminEmail());
    }

    public SkillResponse updateManagedSkill(Integer id, String name, String category) {
        return skillRepository.updateManagedSkill(id, name, category, getCurrentAdminEmail());
    }

    public void deleteManagedSkill(Integer id) {
        skillRepository.deleteManagedSkill(id, getCurrentAdminEmail());
    }

    private String getCurrentAdminEmail() {
        if (!SecurityUtils.isAdmin()) {
            throw new ForbiddenOperationException("Only admins can manage skills");
        }
        String email = SecurityUtils.getCurrentUsername();
        if (email == null || email.isBlank()) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        return email;
    }
}
