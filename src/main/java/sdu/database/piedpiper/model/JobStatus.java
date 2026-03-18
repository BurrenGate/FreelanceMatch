package sdu.database.piedpiper.model;

import lombok.*;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class JobStatus {
    private Integer id;
    private String statusName;
}
