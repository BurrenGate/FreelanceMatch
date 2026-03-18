package sdu.database.piedpiper.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.SubmitProposalRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.model.Proposal;
import sdu.database.piedpiper.service.ProposalService;

import java.util.List;

@RestController
@RequestMapping("/api/proposals")
public class ProposalController {

    private final ProposalService proposalService;

    public ProposalController(ProposalService proposalService) {
        this.proposalService = proposalService;
    }

    @PostMapping("/submit")
    public ResponseEntity<ApiResponse<Void>> submitProposal(@RequestBody SubmitProposalRequest request) {
        try {
            proposalService.submitProposal(request);
            return ResponseEntity.ok(ApiResponse.ok("Заявка успешно отправлена!", null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @GetMapping("/job/{jobId}")
    public ResponseEntity<ApiResponse<List<Proposal>>> getProposalsByJobId(@PathVariable Long jobId) {
        List<Proposal> proposals = proposalService.getProposalsForJob(jobId);
        return ResponseEntity.ok(ApiResponse.ok("Отклики успешно получены", proposals));
    }

    @PostMapping("/{proposalId}/accept")
    public ResponseEntity<ApiResponse<Void>> acceptProposal(@PathVariable Long proposalId) {
        try {
            proposalService.acceptProposal(proposalId);
            return ResponseEntity.ok(ApiResponse.ok(
                    "Заявка принята! Контракт успешно создан, статус задачи изменен на IN_PROGRESS.", null
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}