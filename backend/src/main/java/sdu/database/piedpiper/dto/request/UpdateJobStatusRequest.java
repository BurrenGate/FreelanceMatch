package sdu.database.piedpiper.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdateJobStatusRequest {
    @NotBlank
    private String statusName;
}
