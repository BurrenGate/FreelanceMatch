package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProposalDetailDTO {
    // Proposal info
    private Long proposalId;
    private Long jobId;
    private Long freelancerId;
    private BigDecimal bidAmount;
    private String coverLetter;
    private String status;
    private LocalDateTime createdAt;
    private Boolean isAccepted;
    
    // Job info
    private String jobTitle;
    private String jobDescription;
    private BigDecimal jobMinBudget;
    private BigDecimal jobMaxBudget;
    private String jobStatus;
    
    // Freelancer info
    private String freelancerName;
    private String freelancerEmail;
    private BigDecimal freelancerHourlyRate;
    private BigDecimal freelancerRating;
    private String freelancerBio;
    
    // Client info
    private Long clientId;
    private String clientName;
    private String clientEmail;
}
