package sdu.database.piedpiper.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class JobRequiredSkillResponse {
    private Integer skillId;
    private String skillName;
    private String category;
}
