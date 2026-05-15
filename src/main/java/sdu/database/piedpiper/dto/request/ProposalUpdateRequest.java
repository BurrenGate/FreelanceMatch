package sdu.database.piedpiper.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class ProposalUpdateRequest {
    @NotNull
    @Positive
    private BigDecimal bidAmount;

    private String coverLetter;
}
