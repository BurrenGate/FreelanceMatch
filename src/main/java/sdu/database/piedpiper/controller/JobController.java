package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.response.JobDTO;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.RecommendedJobDTO;
import sdu.database.piedpiper.model.FreelancerMatch;
import sdu.database.piedpiper.model.Job;
import sdu.database.piedpiper.service.JobService;

import java.util.List;

@RestController
@RequestMapping("/api/jobs")
public class JobController {

    private static final Logger log = LoggerFactory.getLogger(JobController.class);

    private final JobService jobService;

    public JobController(JobService jobService) {
        this.jobService = jobService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Job>>> getAllJobs() {
        log.debug("GET /api/jobs");
        List<Job> jobs = jobService.getAllJobs();
        return ResponseEntity.ok(
                ApiResponse.ok("Jobs retrieved successfully", jobs)
        );
    }

    @GetMapping("/my")
    public ResponseEntity<List<Job>> getMyJobs() {
        return ResponseEntity.ok(jobService.getMyJobs());
    }

    @PostMapping
    public void createJob(@RequestBody JobDTO jobDTO) {
        jobService.createJob(jobDTO);
    }

    @GetMapping("/{id}/match")
    public ResponseEntity<ApiResponse<List<FreelancerMatch>>> getMatchingFreelancers(
            @PathVariable Long id) {

        log.debug("GET /api/jobs/{}/match", id);
        try {
            List<FreelancerMatch> matches = jobService.getRecommendedFreelancers(id);
            String msg = matches.isEmpty()
                    ? "No freelancers matched ≥ 50% of the required skills."
                    : matches.size() + " freelancer(s) matched for job " + id;
            return ResponseEntity.ok(ApiResponse.ok(msg, matches));

        } catch (RuntimeException ex) {
            log.warn("Matching procedure error for job {}: {}", id, ex.getMessage());
            return ResponseEntity
                    .badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }

    @GetMapping("/recommended")
    public ResponseEntity<ApiResponse<List<RecommendedJobDTO>>> getRecommendedJobs() {
        log.debug("GET /api/jobs/recommended");

        try {
            List<RecommendedJobDTO> recommendedJobs = jobService.getRecommendedJobs();

            String msg = recommendedJobs.isEmpty()
                    ? "No matching jobs found based on your skills."
                    : "Found " + recommendedJobs.size() + " recommended jobs for you.";

            return ResponseEntity.ok(ApiResponse.ok(msg, recommendedJobs));

        } catch (RuntimeException ex) {
            log.warn("Recommendation error: {}", ex.getMessage());
            return ResponseEntity.badRequest().body(ApiResponse.error(ex.getMessage()));
        }
    }


}
