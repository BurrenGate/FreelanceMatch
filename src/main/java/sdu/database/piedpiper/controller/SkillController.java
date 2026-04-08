package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.model.Skill;
import sdu.database.piedpiper.service.SkillService;

import java.util.List;

@RestController
@RequestMapping("/api/skills")
public class SkillController {

    private static final Logger log = LoggerFactory.getLogger(SkillController.class);
    private final SkillService skillService;

    public SkillController(SkillService skillService) {
        this.skillService = skillService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Skill>>> getAllSkills() {
        try {
            log.debug("GET /api/skills");
            List<Skill> skills = skillService.getAllSkills();
            return ResponseEntity.ok(ApiResponse.ok(
                    skills.isEmpty() ? "No skills found" : "Retrieved " + skills.size() + " skill(s)",
                    skills
            ));
        } catch (Exception ex) {
            log.error("Error getting all skills: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<Skill>> getSkillById(@PathVariable Integer id) {
        try {
            log.debug("GET /api/skills/{}", id);
            return skillService.getSkillById(id)
                    .map(skill -> ResponseEntity.ok(ApiResponse.ok("Skill retrieved successfully", skill)))
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception ex) {
            log.error("Error getting skill: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Skill>> createSkill(@RequestBody Skill skill) {
        try {
            log.debug("POST /api/skills");
            if (skill.getName() == null || skill.getName().trim().isEmpty()) {
                return ResponseEntity.badRequest().body(ApiResponse.error("Skill name is required"));
            }
            Skill created = skillService.createSkill(skill);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Skill created successfully", created));
        } catch (Exception ex) {
            log.error("Error creating skill: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<Skill>> updateSkill(@PathVariable Integer id, @RequestBody Skill skill) {
        try {
            log.debug("PUT /api/skills/{}", id);
            if (skill.getName() == null || skill.getName().trim().isEmpty()) {
                return ResponseEntity.badRequest().body(ApiResponse.error("Skill name is required"));
            }
            Skill updated = skillService.updateSkill(id, skill);
            return ResponseEntity.ok(ApiResponse.ok("Skill updated successfully", updated));
        } catch (Exception ex) {
            log.error("Error updating skill: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteSkill(@PathVariable Integer id) {
        try {
            log.debug("DELETE /api/skills/{}", id);
            skillService.deleteSkill(id);
            return ResponseEntity.ok(ApiResponse.ok("Skill deleted successfully", null));
        } catch (Exception ex) {
            log.error("Error deleting skill: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/category/{category}")
    public ResponseEntity<ApiResponse<List<Skill>>> getSkillsByCategory(@PathVariable String category) {
        try {
            log.debug("GET /api/skills/category/{}", category);
            List<Skill> skills = skillService.getSkillsByCategory(category);
            return ResponseEntity.ok(ApiResponse.ok(
                    skills.isEmpty() ? "No skills found in category: " + category : "Retrieved " + skills.size() + " skill(s)",
                    skills
            ));
        } catch (Exception ex) {
            log.error("Error getting skills by category: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }
}
