package sdu.database.piedpiper.repository;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.ProfileSkillDetailedDTO;
import sdu.database.piedpiper.dto.response.ProfileSkillResponse;
import sdu.database.piedpiper.dto.response.UserSkillDTO;
import sdu.database.piedpiper.model.ProfileSkill;

import java.util.List;

@Repository
public class ProfileSkillRepository {

    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    public ProfileSkillRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = new ObjectMapper();
    }

    public List<ProfileSkill> findByProfileId(Long profileId) {
        String sql = "SELECT profile_id, skill_id, skill_level FROM profile_skills WHERE profile_id = ?";
        return jdbcTemplate.query(
                sql,
                (rs, rowNum) -> new ProfileSkill(
                        rs.getLong("profile_id"),
                        rs.getInt("skill_id"),
                        rs.getString("skill_level")
                ),
                profileId
        );
    }

    public void addSkillsToProfile(String email, List<UserSkillDTO> skills) {
        try {
            String skillsJson = objectMapper.writeValueAsString(skills);
            String sql = "CALL profile_management.add_user_skills(?, ?::jsonb)";
            jdbcTemplate.update(sql, email, skillsJson);

        } catch (JsonProcessingException e) {
            throw new RuntimeException("Error serializing skills to JSON", e);
        }
    }

    public List<ProfileSkillDetailedDTO> getDetailedSkillsByProfileId(Long profileId) {
        String sql = """
            SELECT ps.skill_id, s.name AS skill_name, s.category, ps.skill_level
            FROM profile_skills ps
            JOIN skills s ON ps.skill_id = s.id
            WHERE ps.profile_id = ?
            """;

        return jdbcTemplate.query(sql, (rs, rowNum) ->
                        ProfileSkillDetailedDTO.builder()
                                .skillId(rs.getInt("skill_id"))
                                .skillName(rs.getString("skill_name"))
                                .category(rs.getString("category"))
                                .skillLevel(rs.getString("skill_level"))
                                .build()
                , profileId);
    }

    public List<ProfileSkillDetailedDTO> getAllAvailableSkills() {
        String sql = "SELECT * FROM get_all_available_skills()";

        return jdbcTemplate.query(sql, (rs, rowNum) ->
                ProfileSkillDetailedDTO.builder()
                        .skillId(rs.getInt("skill_id"))
                        .skillName(rs.getString("skill_name"))
                        .category(rs.getString("skill_category")) // Исправлено: колонка называется skill_category
                        .skillLevel(null) // Исправлено: здесь нет уровня, так как навык еще не привязан
                        .build()
        );
    }

    public List<ProfileSkillDetailedDTO> getAvailableSkillsForProfile(Long profileId) {
        String sql = "SELECT * FROM get_available_skills_for_profile(?)";

        return jdbcTemplate.query(sql, (rs, rowNum) ->
                        ProfileSkillDetailedDTO.builder()
                                .skillId(rs.getInt("skill_id"))
                                .skillName(rs.getString("skill_name"))
                                .category(rs.getString("skill_category")) // Исправлено: колонка называется skill_category
                                .skillLevel(null) // Исправлено: здесь нет уровня
                                .build()
                 , profileId);
    }

    public List<ProfileSkillResponse> getMySkills(String email) {
        String sql = "SELECT * FROM profile_management.get_my_skills(?)";
        return jdbcTemplate.query(sql, (rs, rowNum) -> ProfileSkillResponse.builder()
                .skillId(rs.getInt("skill_id"))
                .skillName(rs.getString("skill_name"))
                .category(rs.getString("skill_category"))
                .skillLevel(rs.getString("skill_level"))
                .build(), email);
    }

    public List<ProfileSkillResponse> getMyAvailableSkills(String email) {
        String sql = "SELECT * FROM profile_management.get_my_available_skills(?)";
        return jdbcTemplate.query(sql, (rs, rowNum) -> ProfileSkillResponse.builder()
                .skillId(rs.getInt("skill_id"))
                .skillName(rs.getString("skill_name"))
                .category(rs.getString("skill_category"))
                .skillLevel(null)
                .build(), email);
    }

    public void upsertMySkill(String email, Integer skillId, String skillLevel) {
        String sql = "CALL profile_management.upsert_my_skill(?, ?, ?)";
        jdbcTemplate.update(sql, email, skillId, skillLevel);
    }

    public void deleteMySkill(String email, Integer skillId) {
        String sql = "CALL profile_management.delete_my_skill(?, ?)";
        jdbcTemplate.update(sql, email, skillId);
    }
}
