package sdu.database.piedpiper.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.Profile;

import java.util.Optional;

@Repository
public class ProfileRepository {

    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public ProfileRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Optional<Profile> findByAccountId(Long accountId) {
        String sql = "SELECT * FROM profiles WHERE account_id = ?";
        try {
            Profile profile = jdbcTemplate.queryForObject(sql, new Object[]{accountId}, new BeanPropertyRowMapper<>(Profile.class));
            return Optional.ofNullable(profile);
        } catch (Exception e) {
            return Optional.empty();
        }
    }
}
