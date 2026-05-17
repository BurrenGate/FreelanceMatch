package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClientJobDTO {
    private Long jobId;
    private String title;
    private String description;
    private BigDecimal budget;
    private String status;
    private Integer proposalsCount;
    private LocalDateTime createdAt;
}
