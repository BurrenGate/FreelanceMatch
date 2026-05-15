package sdu.database.piedpiper.controller;

import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.UpdateJobStatusRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.JobStatusResponse;
import sdu.database.piedpiper.security.SecurityUtils;
import sdu.database.piedpiper.service.JobStatusService;

@RestController
@RequestMapping("/api/jobs/{jobId}/status")
public class JobStatusController {

    private final JobStatusService jobStatusService;

    public JobStatusController(JobStatusService jobStatusService) {
        this.jobStatusService = jobStatusService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<JobStatusResponse>> getJobStatus(@PathVariable Long jobId) {
        if (!SecurityUtils.isClient()) {
            return ResponseEntity.status(403).body(ApiResponse.error("Only clients can view owned job status."));
        }
        return ResponseEntity.ok(ApiResponse.ok("Job status retrieved", jobStatusService.getJobStatus(jobId)));
    }

    @PutMapping
    public ResponseEntity<ApiResponse<JobStatusResponse>> updateJobStatus(@PathVariable Long jobId,
                                                                           @Valid @RequestBody UpdateJobStatusRequest request) {
        if (!SecurityUtils.isClient()) {
            return ResponseEntity.status(403).body(ApiResponse.error("Only clients can update owned job status."));
        }
        JobStatusResponse response = jobStatusService.updateJobStatus(jobId, request.getStatusName());
        return ResponseEntity.ok(ApiResponse.ok("Job status updated", response));
    }

}
