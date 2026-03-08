package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.model.ApiResponse;
import sdu.database.piedpiper.model.FreelancerMatch;
import sdu.database.piedpiper.model.Job;
import sdu.database.piedpiper.service.JobService;

import java.util.List;

/**
 * REST Controller  –  exposes three endpoints used by the frontend.
 *
 * GET  /api/jobs              → list all jobs
 * GET  /api/jobs/{id}/match   → call cursor procedure, return freelancer matches
 * POST /api/proposals/{id}/accept → call nested-block procedure, finalize contract
 */
@RestController
@RequestMapping("/api")
public class JobController {

    private static final Logger log = LoggerFactory.getLogger(JobController.class);

    private final JobService jobService;

    public JobController(JobService jobService) {
        this.jobService = jobService;
    }

    // ─── GET /api/jobs ────────────────────────────────────────

    /**
     * Returns every job with its status name so the frontend
     * can display the full list with badges.
     */
    @GetMapping("/jobs")
    public ResponseEntity<ApiResponse<List<Job>>> getAllJobs() {
        log.debug("GET /api/jobs");
        List<Job> jobs = jobService.getAllJobs();
        return ResponseEntity.ok(
                ApiResponse.ok("Jobs retrieved successfully", jobs)
        );
    }

    // ─── GET /api/jobs/{id}/match ─────────────────────────────

    /**
     * Triggers the CURSOR / LOOP procedure (Requirement A) and
     * returns the list of freelancers whose skills match ≥ 50 % of
     * the job's required skills.
     *
     * @param id the job ID
     */
    @GetMapping("/jobs/{id}/match")
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
                    .badRequest()
                    .body(ApiResponse.error(ex.getMessage()));
        }
    }

    // ─── POST /api/proposals/{id}/accept ─────────────────────

    /**
     * Triggers the NESTED BLOCK procedure (Requirement B) which:
     *   1. Validates proposal status = 'pending'
     *   2. Validates job status = 'OPEN'
     *   3. Updates proposal → 'accepted'
     *   4. Updates job → 'IN_PROGRESS'
     *   5. Inserts a new contract record
     *
     * Returns 200 OK on success, or 400 Bad Request if the SQL
     * procedure raises an exception (with the DB message).
     *
     * @param id the proposal ID to accept
     */
    @PostMapping("/proposals/{id}/accept")
    public ResponseEntity<ApiResponse<Void>> acceptProposal(@PathVariable Long id) {
        log.debug("POST /api/proposals/{}/accept", id);
        try {
            jobService.acceptProposal(id);
            return ResponseEntity.ok(
                    ApiResponse.ok("Proposal " + id + " accepted – contract created!", null)
            );
        } catch (RuntimeException ex) {
            log.warn("Accept proposal error for proposal {}: {}", id, ex.getMessage());
            return ResponseEntity
                    .badRequest()
                    .body(ApiResponse.error(ex.getMessage()));
        }
    }
}
