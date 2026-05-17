package sdu.database.piedpiper.dto.response;

import lombok.Builder;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
public class RecommendedJobDTO {
    private Long id;
    private Long clientId;
    private String title;
    private String description;
    private String budgetType;
    private BigDecimal minBudget;
    private BigDecimal maxBudget;
    private String statusName;
    private LocalDateTime createdAt;
    private Double matchPercentage; // Тот самый процент совпадения
}