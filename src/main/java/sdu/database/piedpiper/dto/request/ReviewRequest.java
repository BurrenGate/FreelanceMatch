package sdu.database.piedpiper.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ReviewRequest {
    private Long contractId;
    private Long reviewerId;
    private Integer rating;
    private String comment;
}
