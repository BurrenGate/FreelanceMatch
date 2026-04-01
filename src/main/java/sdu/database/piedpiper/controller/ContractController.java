package sdu.database.piedpiper.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.CompleteJobRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.model.Contract;
import sdu.database.piedpiper.service.ContractService;

import java.util.List;

@RestController
@RequestMapping("/api/contracts")
public class ContractController {

    private final ContractService contractService;

    public ContractController(ContractService contractService) {
        this.contractService = contractService;
    }

    @GetMapping("/my")
    public List<Contract> getMyContracts() {
        return contractService.getMyContracts();
    }

    @PostMapping("/complete")
    public ResponseEntity<ApiResponse<Void>> completeContract(@RequestBody CompleteJobRequest request) {
        try {
            contractService.completeJobAndRate(request);
            return ResponseEntity.ok(ApiResponse.ok(
                    "Контракт успешно завершен! Оплата проведена, отзыв сохранен.", null
            ));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }
}
