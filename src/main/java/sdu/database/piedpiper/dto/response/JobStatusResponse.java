package sdu.database.piedpiper.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class JobStatusResponse {
    private Long jobId;
    private Integer statusId;
    private String statusName;
}
