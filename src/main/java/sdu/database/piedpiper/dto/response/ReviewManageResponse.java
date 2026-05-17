package sdu.database.piedpiper.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ReviewManageResponse {
    private Long id;
    private Long contractId;
    private Long reviewerId;
    private Integer rating;
    private String comment;
}
