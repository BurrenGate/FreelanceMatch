package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.response.RoleResponse;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.model.Role;
import sdu.database.piedpiper.repository.RoleRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;
import java.util.Optional;

@Service
public class RoleService {

    private static final Logger log = LoggerFactory.getLogger(RoleService.class);
    private final RoleRepository roleRepository;

    public RoleService(RoleRepository roleRepository) {
        this.roleRepository = roleRepository;
    }

    public List<Role> getAllRoles() {
        log.info("Fetching all roles");
        return roleRepository.findAll();
    }

    public Optional<Role> getRoleById(Integer id) {
        log.info("Fetching role with id: {}", id);
        return roleRepository.findById(id);
    }

    public Optional<Role> getRoleByName(String name) {
        log.info("Fetching role by name: {}", name);
        return roleRepository.findByName(name);
    }

    public List<RoleResponse> getManagedRoles() {
        return roleRepository.getManagedRoles(getCurrentAdminEmail());
    }

    public RoleResponse createRole(String name) {
        return roleRepository.createRole(name, getCurrentAdminEmail());
    }

    public RoleResponse updateRole(Integer roleId, String name) {
        return roleRepository.updateRole(roleId, name, getCurrentAdminEmail());
    }

    public void deleteRole(Integer roleId) {
        roleRepository.deleteRole(roleId, getCurrentAdminEmail());
    }

    private String getCurrentAdminEmail() {
        if (!SecurityUtils.isAdmin()) {
            throw new ForbiddenOperationException("Only admins can manage roles");
        }
        String email = SecurityUtils.getCurrentUsername();
        if (email == null || email.isBlank()) {
            throw new ForbiddenOperationException("User is not authenticated");
        }
        return email;
    }
}
