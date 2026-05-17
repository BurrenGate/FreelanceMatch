package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentSummaryDTO {
    private Long contractId;
    private BigDecimal totalAmount;
    private BigDecimal paidAmount;
    private BigDecimal remainingAmount;
    private Integer totalMilestones;
    private Integer pendingMilestones;
    private Integer completedMilestones;
    private Integer paidMilestones;
}
