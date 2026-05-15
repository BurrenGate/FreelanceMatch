package sdu.database.piedpiper.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UpsertProfileSkillRequest {

    @NotNull
    private Integer skillId;

    @NotBlank
    private String skillLevel;
}
