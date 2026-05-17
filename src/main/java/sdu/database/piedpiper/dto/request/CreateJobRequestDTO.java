package sdu.database.piedpiper.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateJobRequestDTO {
    private Long clientId;
    private String title;
    private String description;
    private String budgetType;
    private java.math.BigDecimal minBudget;
    private java.math.BigDecimal maxBudget;
    private java.time.LocalDate applicationDeadline;
    private java.time.LocalDate startDate;
    private java.time.LocalDate endDate;
}
