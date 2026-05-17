package sdu.database.piedpiper.dto.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class JobStatusManageResponse {
    private Integer id;
    private String statusName;
}
