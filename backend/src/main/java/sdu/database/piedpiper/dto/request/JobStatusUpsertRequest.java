package sdu.database.piedpiper.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class JobStatusUpsertRequest {

    @NotBlank
    private String statusName;
}
