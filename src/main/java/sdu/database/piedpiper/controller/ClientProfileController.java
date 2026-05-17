package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.ClientProfileDTO;
import sdu.database.piedpiper.service.ClientProfileService;

@RestController
@RequestMapping("/api/clients")
public class ClientProfileController {

    private static final Logger log = LoggerFactory.getLogger(ClientProfileController.class);
    private final ClientProfileService clientProfileService;

    public ClientProfileController(ClientProfileService clientProfileService) {
        this.clientProfileService = clientProfileService;
    }

    @GetMapping("/{clientId}/profile")
    public ResponseEntity<ApiResponse<ClientProfileDTO>> getClientProfile(@PathVariable Long clientId) {
        log.debug("GET /api/clients/{}/profile", clientId);
        try {
            ClientProfileDTO profile = clientProfileService.getClientProfile(clientId);
            return ResponseEntity.ok(ApiResponse.ok(
                    "Client profile retrieved successfully",
                    profile
            ));
        } catch (Exception e) {
            log.error("Error getting client profile: {}", e.getMessage(), e);
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}
