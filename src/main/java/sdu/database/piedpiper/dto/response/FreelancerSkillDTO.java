package sdu.database.piedpiper.dto.response;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FreelancerSkillDTO {
    private Integer skillId;
    private String skillName;
    private String skillCategory;
    private String skillLevel;
}
