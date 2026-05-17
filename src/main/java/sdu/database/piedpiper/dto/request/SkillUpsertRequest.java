package sdu.database.piedpiper.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class SkillUpsertRequest {

    @NotBlank
    private String name;

    @NotBlank
    private String category;
}
