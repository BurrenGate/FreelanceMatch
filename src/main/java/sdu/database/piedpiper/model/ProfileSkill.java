package sdu.database.piedpiper.model;

import lombok.*;

// Таблицы связей (Many-to-Many)
@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class ProfileSkill {
    private Long profileId;
    private Integer skillId;
    private String skillLevel;
}
