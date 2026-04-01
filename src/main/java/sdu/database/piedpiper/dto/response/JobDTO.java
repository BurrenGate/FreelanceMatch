package sdu.database.piedpiper.dto.response;

import lombok.Data;
import java.util.List;

@Data
public class JobDTO {
    private String title;
    private String description;
    private Double budget;
    private List<Long> requiredSkillIds;
}
