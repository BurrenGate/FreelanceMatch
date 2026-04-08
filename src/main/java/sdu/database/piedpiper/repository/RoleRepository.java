package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.Role;

import java.util.List;
import java.util.Optional;

@Repository
public class RoleRepository {

    private static final Logger log = LoggerFactory.getLogger(RoleRepository.class);
    private final JdbcTemplate jdbc;

    public RoleRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<Role> ROLE_MAPPER = (rs, rowNum) -> {
        Role r = new Role();
        r.setId(rs.getInt("id"));
        r.setName(rs.getString("name"));
        return r;
    };

    public List<Role> findAll() {
        String sql = "SELECT id, name FROM roles ORDER BY id ASC";
        log.debug("Executing findAll() roles query");
        return jdbc.query(sql, ROLE_MAPPER);
    }

    public Optional<Role> findById(Integer id) {
        String sql = "SELECT id, name FROM roles WHERE id = ?";
        try {
            Role role = jdbc.queryForObject(sql, ROLE_MAPPER, id);
            return Optional.of(role);
        } catch (Exception e) {
            log.debug("Role not found with id: {}", id);
            return Optional.empty();
        }
    }

    public Optional<Role> findByName(String name) {
        String sql = "SELECT id, name FROM roles WHERE name = ?";
        try {
            Role role = jdbc.queryForObject(sql, ROLE_MAPPER, name);
            return Optional.of(role);
        } catch (Exception e) {
            log.debug("Role not found with name: {}", name);
            return Optional.empty();
        }
    }
}
