package sdu.database.piedpiper.controller;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.JobStatusUpsertRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.JobStatusManageResponse;
import sdu.database.piedpiper.service.JobStatusService;

import java.util.List;

@RestController
@RequestMapping("/api/job-statuses/manage")
public class AdminJobStatusController {

    private final JobStatusService jobStatusService;

    public AdminJobStatusController(JobStatusService jobStatusService) {
        this.jobStatusService = jobStatusService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<JobStatusManageResponse>>> getManagedJobStatuses() {
        List<JobStatusManageResponse> statuses = jobStatusService.getManagedJobStatuses();
        return ResponseEntity.ok(ApiResponse.ok("Job statuses retrieved successfully", statuses));
    }

    @PostMapping
    public ResponseEntity<ApiResponse<JobStatusManageResponse>> createManagedJobStatus(@Valid @RequestBody JobStatusUpsertRequest request) {
        JobStatusManageResponse response = jobStatusService.createManagedJobStatus(request.getStatusName());
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Job status created successfully", response));
    }

    @PutMapping("/{statusId}")
    public ResponseEntity<ApiResponse<JobStatusManageResponse>> updateManagedJobStatus(@PathVariable Integer statusId,
                                                                                        @Valid @RequestBody JobStatusUpsertRequest request) {
        JobStatusManageResponse response = jobStatusService.updateManagedJobStatus(statusId, request.getStatusName());
        return ResponseEntity.ok(ApiResponse.ok("Job status updated successfully", response));
    }

    @DeleteMapping("/{statusId}")
    public ResponseEntity<ApiResponse<Void>> deleteManagedJobStatus(@PathVariable Integer statusId) {
        jobStatusService.deleteManagedJobStatus(statusId);
        return ResponseEntity.ok(ApiResponse.ok("Job status deleted successfully", null));
    }
}
