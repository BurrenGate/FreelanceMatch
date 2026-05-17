package sdu.database.piedpiper.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ReviewUpsertRequest {

    @NotNull
    private Long contractId;

    @NotNull
    private Long reviewerId;

    @NotNull
    @Min(1)
    @Max(5)
    private Integer rating;

    private String comment;
}
