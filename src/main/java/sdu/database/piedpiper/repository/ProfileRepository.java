package sdu.database.piedpiper.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.ProfileDTO;
import sdu.database.piedpiper.dto.response.UpdateProfileDTO;
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

    public Optional<ProfileDTO> getFullProfileByEmail(String email) {
        // Вся логика сбора данных перенесена на сторону PostgreSQL
        String sql = """
            SELECT 
                a.id AS account_id, a.email, r.name AS role_name, a.status AS account_status, 
                a.last_login, a.created_at AS account_created_at,
                p.id AS profile_id, p.first_name, p.last_name, p.bio, p.hourly_rate, 
                p.avatar_url, p.updated_at AS profile_updated_at,
                (SELECT COALESCE(AVG(rating), 0) FROM reviews rev JOIN contracts c ON rev.contract_id = c.id WHERE c.freelancer_id = p.id) AS rating,
                (SELECT COALESCE(SUM(amount), 0) FROM transactions t JOIN contracts c ON t.contract_id = c.id WHERE c.freelancer_id = p.id) AS balance
            FROM accounts a
            LEFT JOIN roles r ON a.role_id = r.id
            LEFT JOIN profiles p ON p.account_id = a.id
            WHERE a.email = ?
            """;

        try {
            ProfileDTO dto = jdbcTemplate.queryForObject(sql, (rs, rowNum) ->
                            ProfileDTO.builder()
                                    .accountId(rs.getLong("account_id"))
                                    .email(rs.getString("email"))
                                    .role(rs.getString("role_name"))
                                    .accountStatus(rs.getString("account_status"))
                                    .lastLogin(rs.getTimestamp("last_login") != null ? rs.getTimestamp("last_login").toLocalDateTime() : null)
                                    .accountCreatedAt(rs.getTimestamp("account_created_at") != null ? rs.getTimestamp("account_created_at").toLocalDateTime() : null)
                                    .profileId(rs.getObject("profile_id") != null ? rs.getLong("profile_id") : null)
                                    .firstName(rs.getString("first_name"))
                                    .lastName(rs.getString("last_name"))
                                    .bio(rs.getString("bio"))
                                    .hourlyRate(rs.getBigDecimal("hourly_rate"))
                                    .avatarUrl(rs.getString("avatar_url"))
                                    .profileUpdatedAt(rs.getTimestamp("profile_updated_at") != null ? rs.getTimestamp("profile_updated_at").toLocalDateTime() : null)
                                    .rating(rs.getDouble("rating"))
                                    .balance(rs.getBigDecimal("balance"))
                                    .build()
                    , email);
            return Optional.ofNullable(dto);
        } catch (Exception e) {
            return Optional.empty();
        }
    }


    public void updateProfile(String email, UpdateProfileDTO dto) {
        String sql = "CALL profile_management.update_profile(?, ?, ?, ?, ?, ?)";

        jdbcTemplate.update(
                sql,
                email,
                dto.getFirstName(),
                dto.getLastName(),
                dto.getBio(),
                dto.getHourlyRate(),
                dto.getAvatarUrl()
        );
    }
}
