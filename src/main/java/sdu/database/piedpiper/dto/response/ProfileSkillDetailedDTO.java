package sdu.database.piedpiper.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProfileSkillDetailedDTO {
    
    private Integer skillId;
    
    // Из таблицы skills
    private String skillName;
    private String category;
    
    // Из таблицы profile_skills
    private String skillLevel;
}