package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.SkillResponse;
import sdu.database.piedpiper.model.Skill;

import java.util.List;
import java.util.Optional;

@Repository
public class SkillRepository {

    private static final Logger log = LoggerFactory.getLogger(SkillRepository.class);
    private final JdbcTemplate jdbc;

    public SkillRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<Skill> SKILL_MAPPER = (rs, rowNum) -> {
        Skill s = new Skill();
        s.setId(rs.getInt("id"));
        s.setName(rs.getString("name"));
        s.setCategory(rs.getString("category"));
        return s;
    };

    private static final RowMapper<SkillResponse> SKILL_RESPONSE_MAPPER = (rs, rowNum) -> SkillResponse.builder()
            .id(rs.getInt("id"))
            .name(rs.getString("name"))
            .category(rs.getString("category"))
            .build();

    public List<Skill> findAll() {
        String sql = "SELECT * FROM app_management.get_skills()";
        log.debug("Executing findAll() skills query");
        return jdbc.query(sql, SKILL_MAPPER);
    }

    public Optional<Skill> findById(Integer id) {
        String sql = "SELECT * FROM app_management.get_skill_by_id(?)";
        try {
            Skill skill = jdbc.queryForObject(sql, SKILL_MAPPER, id);
            return Optional.of(skill);
        } catch (Exception e) {
            log.debug("Skill not found with id: {}", id);
            return Optional.empty();
        }
    }

    public Skill save(Skill skill) {
        String sql = "CALL app_management.upsert_skill(?, ?, ?)";
        jdbc.update(sql, skill.getId(), skill.getName(), skill.getCategory());
        return skill;
    }

    public void deleteById(Integer id) {
        String sql = "CALL app_management.delete_skill(?)";
        int deleted = jdbc.update(sql, id);
        if (deleted > 0) {
            log.info("Skill deleted: {}", id);
        } else {
            log.warn("No skill found with id: {}", id);
        }
    }

    public List<Skill> findByCategory(String category) {
        String sql = "SELECT * FROM app_management.get_skills_by_category(?)";
        return jdbc.query(sql, SKILL_MAPPER, category);
    }

    public List<SkillResponse> getManagedSkills(String category, String adminEmail) {
        String sql = "SELECT * FROM admin_management.get_skills(?, ?)";
        return jdbc.query(sql, SKILL_RESPONSE_MAPPER, category, adminEmail);
    }

    public SkillResponse getManagedSkillById(Integer id, String adminEmail) {
        String sql = "SELECT * FROM admin_management.get_skill_by_id(?, ?)";
        return jdbc.queryForObject(sql, SKILL_RESPONSE_MAPPER, id, adminEmail);
    }

    public SkillResponse createManagedSkill(String name, String category, String adminEmail) {
        String sql = "SELECT * FROM admin_management.create_skill(?, ?, ?)";
        return jdbc.queryForObject(sql, SKILL_RESPONSE_MAPPER, name, category, adminEmail);
    }

    public SkillResponse updateManagedSkill(Integer id, String name, String category, String adminEmail) {
        String sql = "SELECT * FROM admin_management.update_skill(?, ?, ?, ?)";
        return jdbc.queryForObject(sql, SKILL_RESPONSE_MAPPER, id, name, category, adminEmail);
    }

    public void deleteManagedSkill(Integer id, String adminEmail) {
        String sql = "CALL admin_management.delete_skill(?, ?)";
        jdbc.update(sql, id, adminEmail);
    }
}
