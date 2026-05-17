package sdu.database.piedpiper.model;

import lombok.*;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class JobRequiredSkill {
    private Long jobId;
    private Integer skillId;
}
