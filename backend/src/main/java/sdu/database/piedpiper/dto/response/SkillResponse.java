package sdu.database.piedpiper.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SkillResponse {
    private Integer id;
    private String name;
    private String category;
}
