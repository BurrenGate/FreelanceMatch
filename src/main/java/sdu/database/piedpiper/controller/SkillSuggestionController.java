package sdu.database.piedpiper.controller;

import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.ReviewSkillSuggestionRequest;
import sdu.database.piedpiper.dto.request.SuggestSkillRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.MySkillSuggestionDTO;
import sdu.database.piedpiper.dto.response.SkillSuggestionDTO;
import sdu.database.piedpiper.dto.response.SkillSuggestionStatsDTO;
import sdu.database.piedpiper.service.SkillSuggestionService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/skill-suggestions")
public class SkillSuggestionController {

    private static final Logger log = LoggerFactory.getLogger(SkillSuggestionController.class);
    private final SkillSuggestionService skillSuggestionService;

    public SkillSuggestionController(SkillSuggestionService skillSuggestionService) {
        this.skillSuggestionService = skillSuggestionService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Map<String, Object>>> suggestSkill(@Valid @RequestBody SuggestSkillRequest request) {
        log.debug("POST /api/skill-suggestions - suggesting skill: {}", request.getName());
        try {
            Map<String, Object> result = skillSuggestionService.suggestSkill(request);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Skill suggestion submitted successfully. Waiting for admin approval.", result));
        } catch (Exception e) {
            log.error("Error suggesting skill: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error("Failed to suggest skill: " + e.getMessage()));
        }
    }

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<MySkillSuggestionDTO>>> getMySkillSuggestions() {
        log.debug("GET /api/skill-suggestions/my");
        try {
            List<MySkillSuggestionDTO> suggestions = skillSuggestionService.getMySkillSuggestions();
            return ResponseEntity.ok(ApiResponse.ok(
                    suggestions.isEmpty() ? "No skill suggestions found" : "Retrieved " + suggestions.size() + " suggestion(s)",
                    suggestions
            ));
        } catch (Exception e) {
            log.error("Error getting my skill suggestions: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error("Failed to retrieve suggestions: " + e.getMessage()));
        }
    }

    @GetMapping("/admin")
    public ResponseEntity<ApiResponse<List<SkillSuggestionDTO>>> getAllSkillSuggestions(
            @RequestParam(required = false) String status) {
        log.debug("GET /api/skill-suggestions/admin - status: {}", status);
        try {
            List<SkillSuggestionDTO> suggestions = skillSuggestionService.getAllSkillSuggestions(status);
            return ResponseEntity.ok(ApiResponse.ok(
                    suggestions.isEmpty() ? "No skill suggestions found" : "Retrieved " + suggestions.size() + " suggestion(s)",
                    suggestions
            ));
        } catch (Exception e) {
            log.error("Error getting skill suggestions: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error("Failed to retrieve suggestions: " + e.getMessage()));
        }
    }

    @PostMapping("/{id}/approve")
    public ResponseEntity<ApiResponse<Map<String, Object>>> approveSkillSuggestion(
            @PathVariable Long id,
            @RequestBody(required = false) ReviewSkillSuggestionRequest request) {
        log.debug("POST /api/skill-suggestions/{}/approve", id);
        try {
            Map<String, Object> result = skillSuggestionService.approveSkillSuggestion(id, request);
            return ResponseEntity.ok(ApiResponse.ok("Skill suggestion approved successfully", result));
        } catch (Exception e) {
            log.error("Error approving skill suggestion: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error("Failed to approve suggestion: " + e.getMessage()));
        }
    }

    @PostMapping("/{id}/reject")
    public ResponseEntity<ApiResponse<Map<String, Object>>> rejectSkillSuggestion(
            @PathVariable Long id,
            @Valid @RequestBody ReviewSkillSuggestionRequest request) {
        log.debug("POST /api/skill-suggestions/{}/reject", id);
        try {
            Map<String, Object> result = skillSuggestionService.rejectSkillSuggestion(id, request);
            return ResponseEntity.ok(ApiResponse.ok("Skill suggestion rejected", result));
        } catch (Exception e) {
            log.error("Error rejecting skill suggestion: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error("Failed to reject suggestion: " + e.getMessage()));
        }
    }

    @GetMapping("/admin/statistics")
    public ResponseEntity<ApiResponse<SkillSuggestionStatsDTO>> getSuggestionStatistics() {
        log.debug("GET /api/skill-suggestions/admin/statistics");
        try {
            SkillSuggestionStatsDTO stats = skillSuggestionService.getSuggestionStatistics();
            return ResponseEntity.ok(ApiResponse.ok("Statistics retrieved successfully", stats));
        } catch (Exception e) {
            log.error("Error getting suggestion statistics: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error("Failed to retrieve statistics: " + e.getMessage()));
        }
    }
}
