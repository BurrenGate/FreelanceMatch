package sdu.database.piedpiper.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ContractRequest {
    @NotNull
    @Positive
    private Long jobId;

    @NotNull
    @Positive
    private Long freelancerId;

    @NotNull
    @Positive
    private BigDecimal totalAmount;

    @NotBlank
    private String status;
}
