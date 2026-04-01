package sdu.database.piedpiper.model;

import lombok.*;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class ProfileSkill {
    private Long profileId;
    private Integer skillId;
    private String skillLevel;
}
