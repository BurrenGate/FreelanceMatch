package sdu.database.piedpiper.model;

import lombok.*;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class Skill {
    private Integer id;
    private String name;
    private String category;
}
