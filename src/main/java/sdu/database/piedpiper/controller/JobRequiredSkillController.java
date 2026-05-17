package sdu.database.piedpiper.controller;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.JobRequiredSkillRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.JobRequiredSkillResponse;
import sdu.database.piedpiper.security.SecurityUtils;
import sdu.database.piedpiper.service.JobRequiredSkillService;

import java.util.List;

@RestController
@RequestMapping("/api/jobs/{jobId}/required-skills")
public class JobRequiredSkillController {

    private final JobRequiredSkillService jobRequiredSkillService;

    public JobRequiredSkillController(JobRequiredSkillService jobRequiredSkillService) {
        this.jobRequiredSkillService = jobRequiredSkillService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<JobRequiredSkillResponse>>> getRequiredSkills(@PathVariable Long jobId) {
        if (!SecurityUtils.isClient()) {
            return ResponseEntity.status(403)
                    .body(ApiResponse.error("Only clients can view required skills of owned jobs."));
        }
        List<JobRequiredSkillResponse> skills = jobRequiredSkillService.getRequiredSkills(jobId);
        return ResponseEntity.ok(ApiResponse.ok("Required skills retrieved successfully", skills));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<Void>> addRequiredSkill(@PathVariable Long jobId,
                                                               @Valid @RequestBody JobRequiredSkillRequest request) {
        if (!SecurityUtils.isClient()) {
            return ResponseEntity.status(403)
                    .body(ApiResponse.error("Only clients can manage required skills."));
        }
        jobRequiredSkillService.addRequiredSkill(jobId, request.getSkillId());
        return ResponseEntity.ok(ApiResponse.ok("Required skill added", null));
    }

    @DeleteMapping("/{skillId}")
    public ResponseEntity<ApiResponse<Void>> removeRequiredSkill(@PathVariable Long jobId,
                                                                  @PathVariable Integer skillId) {
        if (!SecurityUtils.isClient()) {
            return ResponseEntity.status(403)
                    .body(ApiResponse.error("Only clients can manage required skills."));
        }
        jobRequiredSkillService.removeRequiredSkill(jobId, skillId);
        return ResponseEntity.ok(ApiResponse.ok("Required skill removed", null));
    }
}
