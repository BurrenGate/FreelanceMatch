package sdu.database.piedpiper.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import java.math.BigDecimal;

@Data
public class CompleteJobRequest {
    private Long contractId;

    @NotNull
    @Min(1)
    @Max(5)
    private BigDecimal rating;

    private String feedback;
}
