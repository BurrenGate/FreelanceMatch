package sdu.database.piedpiper.model;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class Proposal {
    private Long id;
    private Long jobId;
    private Long freelancerId;
    private BigDecimal bidAmount;
    private Integer deliveryDays;
    private String coverLetter;
    private String status;
    private LocalDateTime createdAt;
}
