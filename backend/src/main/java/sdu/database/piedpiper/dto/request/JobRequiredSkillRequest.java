package sdu.database.piedpiper.dto.request;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class JobRequiredSkillRequest {
    @NotNull
    @Positive
    private Integer skillId;
}
