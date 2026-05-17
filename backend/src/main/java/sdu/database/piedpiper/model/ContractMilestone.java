package sdu.database.piedpiper.model;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContractMilestone {
    private Long id;
    private Long contractId;
    private String title;
    private String description;
    private BigDecimal amount;
    private String status;
    private LocalDate dueDate;
    private LocalDateTime completedAt;
    private LocalDateTime paidAt;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
