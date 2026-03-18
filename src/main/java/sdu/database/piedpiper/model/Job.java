package sdu.database.piedpiper.model;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Job {
    private Long          id;
    private Long          clientId;
    private String        title;
    private String        description;
    private String        budgetType;
    private BigDecimal    minBudget;
    private BigDecimal    maxBudget;
    private String        statusName;
    private LocalDateTime createdAt;
}
