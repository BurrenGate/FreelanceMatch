package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.RoleUpsertRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.RoleResponse;
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

    @GetMapping("/manage")
    public ResponseEntity<ApiResponse<List<RoleResponse>>> getManagedRoles() {
        List<RoleResponse> roles = roleService.getManagedRoles();
        return ResponseEntity.ok(ApiResponse.ok("Roles retrieved successfully", roles));
    }

    @PostMapping("/manage")
    public ResponseEntity<ApiResponse<RoleResponse>> createRole(@Valid @RequestBody RoleUpsertRequest request) {
        RoleResponse created = roleService.createRole(request.getName());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Role created successfully", created));
    }

    @PutMapping("/manage/{roleId}")
    public ResponseEntity<ApiResponse<RoleResponse>> updateRole(@PathVariable Integer roleId,
                                                                @Valid @RequestBody RoleUpsertRequest request) {
        RoleResponse updated = roleService.updateRole(roleId, request.getName());
        return ResponseEntity.ok(ApiResponse.ok("Role updated successfully", updated));
    }

    @DeleteMapping("/manage/{roleId}")
    public ResponseEntity<ApiResponse<Void>> deleteRole(@PathVariable Integer roleId) {
        roleService.deleteRole(roleId);
        return ResponseEntity.ok(ApiResponse.ok("Role deleted successfully", null));
    }
}
