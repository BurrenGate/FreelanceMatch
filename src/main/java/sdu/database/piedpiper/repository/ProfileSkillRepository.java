package sdu.database.piedpiper.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.ProfileSkill;

import java.util.List;

@Repository
public class ProfileSkillRepository {

    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public ProfileSkillRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<ProfileSkill> findByProfileId(Long profileId) {
        String sql = "SELECT profile_id, skill_id, skill_level FROM profile_skills WHERE profile_id = ?";
        return jdbcTemplate.query(
                sql,
                new Object[]{profileId},
                (rs, rowNum) -> new ProfileSkill(
                        rs.getLong("profile_id"),
                        rs.getInt("skill_id"),
                        rs.getString("skill_level")
                )
        );
    }

    public ProfileSkill save(ProfileSkill profileSkill) {
        String sql = "INSERT INTO profile_skills (profile_id, skill_id, skill_level) VALUES (?, ?, ?)";
        jdbcTemplate.update(
                sql,
                profileSkill.getProfileId(),
                profileSkill.getSkillId(),
                profileSkill.getSkillLevel()
        );
        return profileSkill;
    }
}
