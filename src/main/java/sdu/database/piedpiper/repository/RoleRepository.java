package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.RoleResponse;
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

    private static final RowMapper<RoleResponse> ROLE_RESPONSE_MAPPER = (rs, rowNum) -> RoleResponse.builder()
            .id(rs.getInt("id"))
            .name(rs.getString("name"))
            .build();

    public List<Role> findAll() {
        String sql = "SELECT * FROM app_management.get_roles()";
        log.debug("Executing findAll() roles query");
        return jdbc.query(sql, ROLE_MAPPER);
    }

    public Optional<Role> findById(Integer id) {
        String sql = "SELECT * FROM app_management.get_role_by_id(?)";
        try {
            Role role = jdbc.queryForObject(sql, ROLE_MAPPER, id);
            return Optional.of(role);
        } catch (Exception e) {
            log.debug("Role not found with id: {}", id);
            return Optional.empty();
        }
    }

    public Optional<Role> findByName(String name) {
        String sql = "SELECT * FROM app_management.get_role_by_name(?)";
        try {
            Role role = jdbc.queryForObject(sql, ROLE_MAPPER, name);
            return Optional.of(role);
        } catch (Exception e) {
            log.debug("Role not found with name: {}", name);
            return Optional.empty();
        }
    }

    public List<RoleResponse> getManagedRoles(String adminEmail) {
        String sql = "SELECT * FROM admin_management.get_roles(?)";
        return jdbc.query(sql, ROLE_RESPONSE_MAPPER, adminEmail);
    }

    public RoleResponse createRole(String name, String adminEmail) {
        String sql = "SELECT * FROM admin_management.create_role(?, ?)";
        return jdbc.queryForObject(sql, ROLE_RESPONSE_MAPPER, name, adminEmail);
    }

    public RoleResponse updateRole(Integer roleId, String name, String adminEmail) {
        String sql = "SELECT * FROM admin_management.update_role(?, ?, ?)";
        return jdbc.queryForObject(sql, ROLE_RESPONSE_MAPPER, roleId, name, adminEmail);
    }

    public void deleteRole(Integer roleId, String adminEmail) {
        String sql = "CALL admin_management.delete_role(?, ?)";
        jdbc.update(sql, roleId, adminEmail);
    }
}
