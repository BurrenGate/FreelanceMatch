package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContractDetailsDTO {
    private Long contractId;
    private Long jobId;
    private String jobTitle;
    private Long freelancerId;
    private String freelancerName;
    private Long clientId;
    private String clientName;
    private BigDecimal totalAmount;
    private String status;
    private Long cancellationRequestedBy;
    private String cancellationRequesterName;
    private LocalDateTime cancellationRequestedAt;
    private String cancellationReason;
    private LocalDateTime createdAt;
}
