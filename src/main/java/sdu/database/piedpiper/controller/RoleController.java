package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.model.Role;
import sdu.database.piedpiper.service.RoleService;

import java.util.List;

@RestController
@RequestMapping("/api/roles")
public class RoleController {

    private static final Logger log = LoggerFactory.getLogger(RoleController.class);
    private final RoleService roleService;

    public RoleController(RoleService roleService) {
        this.roleService = roleService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Role>>> getAllRoles() {
        try {
            log.debug("GET /api/roles");
            List<Role> roles = roleService.getAllRoles();
            return ResponseEntity.ok(ApiResponse.ok(
                    roles.isEmpty() ? "No roles found" : "Retrieved " + roles.size() + " role(s)",
                    roles
            ));
        } catch (Exception ex) {
            log.error("Error getting all roles: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Role>> getRoleById(@PathVariable Integer id) {
        try {
            log.debug("GET /api/roles/{}", id);
            return roleService.getRoleById(id)
                    .map(role -> ResponseEntity.ok(ApiResponse.ok("Role retrieved successfully", role)))
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception ex) {
            log.error("Error getting role: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/name/{name}")
    public ResponseEntity<ApiResponse<Role>> getRoleByName(@PathVariable String name) {
        try {
            log.debug("GET /api/roles/name/{}", name);
            return roleService.getRoleByName(name)
                    .map(role -> ResponseEntity.ok(ApiResponse.ok("Role retrieved successfully", role)))
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception ex) {
            log.error("Error getting role by name: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }
}
