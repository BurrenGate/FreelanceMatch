package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
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

    public List<Skill> findAll() {
        String sql = "SELECT id, name, category FROM skills ORDER BY name ASC";
        log.debug("Executing findAll() skills query");
        return jdbc.query(sql, SKILL_MAPPER);
    }

    public Optional<Skill> findById(Integer id) {
        String sql = "SELECT id, name, category FROM skills WHERE id = ?";
        try {
            Skill skill = jdbc.queryForObject(sql, SKILL_MAPPER, id);
            return Optional.of(skill);
        } catch (Exception e) {
            log.debug("Skill not found with id: {}", id);
            return Optional.empty();
        }
    }

    public Skill save(Skill skill) {
        if (skill.getId() != null) {
            String sql = "UPDATE skills SET name = ?, category = ? WHERE id = ?";
            jdbc.update(sql, skill.getName(), skill.getCategory(), skill.getId());
            log.info("Skill updated: {}", skill.getId());
        } else {
            String sql = "INSERT INTO skills (name, category) VALUES (?, ?)";
            jdbc.update(sql, skill.getName(), skill.getCategory());
            log.info("Skill created: {}", skill.getName());
        }
        return skill;
    }

    public void deleteById(Integer id) {
        String sql = "DELETE FROM skills WHERE id = ?";
        int deleted = jdbc.update(sql, id);
        if (deleted > 0) {
            log.info("Skill deleted: {}", id);
        } else {
            log.warn("No skill found with id: {}", id);
        }
    }

    public List<Skill> findByCategory(String category) {
        String sql = "SELECT id, name, category FROM skills WHERE category = ? ORDER BY name ASC";
        return jdbc.query(sql, SKILL_MAPPER, category);
    }
}
