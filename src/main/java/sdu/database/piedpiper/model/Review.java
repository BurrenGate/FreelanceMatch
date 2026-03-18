package sdu.database.piedpiper.model;

import lombok.*;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class Review {
    private Long id;
    private Long contractId;
    private Long reviewerId;
    private Integer rating;
    private String comment;
}
