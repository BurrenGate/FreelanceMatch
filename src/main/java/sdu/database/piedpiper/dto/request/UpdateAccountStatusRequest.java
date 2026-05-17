package sdu.database.piedpiper.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UpdateAccountStatusRequest {

    @NotBlank
    private String status;
}
