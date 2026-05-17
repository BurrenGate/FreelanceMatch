package sdu.database.piedpiper.dto.response;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;
import java.util.List;

@Data
public class JobDTO {
    @NotBlank
    private String title;

    @NotBlank
    private String description;

    @NotNull
    @Positive
    private Double budget;

    @NotEmpty
    private List<Long> requiredSkillIds;
}
