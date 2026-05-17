package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.FreelancerProfileDTO;
import sdu.database.piedpiper.service.FreelancerProfileService;

@RestController
@RequestMapping("/api/freelancers")
public class FreelancerProfileController {

    private static final Logger log = LoggerFactory.getLogger(FreelancerProfileController.class);
    private final FreelancerProfileService freelancerProfileService;

    public FreelancerProfileController(FreelancerProfileService freelancerProfileService) {
        this.freelancerProfileService = freelancerProfileService;
    }

    @GetMapping("/{freelancerId}/profile")
    public ResponseEntity<ApiResponse<FreelancerProfileDTO>> getFreelancerProfile(@PathVariable Long freelancerId) {
        log.debug("GET /api/freelancers/{}/profile", freelancerId);
        try {
            FreelancerProfileDTO profile = freelancerProfileService.getFreelancerProfile(freelancerId);
            return ResponseEntity.ok(ApiResponse.ok(
                    "Freelancer profile retrieved successfully",
                    profile
            ));
        } catch (Exception e) {
            log.error("Error getting freelancer profile: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}
