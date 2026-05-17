package sdu.database.piedpiper.dto.request;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CreateProposalRequestDTO {
    private Long jobId;
    private Long freelancerId;
    private BigDecimal bidAmount;
    private Integer deliveryDays;
    private String coverLetter;
}
