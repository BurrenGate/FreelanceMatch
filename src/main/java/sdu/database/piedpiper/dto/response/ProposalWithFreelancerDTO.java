package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProposalWithFreelancerDTO {
    private Long id;
    private Long jobId;
    private Long freelancerId;
    private BigDecimal bidAmount;
    private Integer deliveryDays;
    private String coverLetter;
    private String status;
    private LocalDateTime createdAt;
    
    // Freelancer details
    private String freelancerName;
    private String freelancerEmail;
    private BigDecimal freelancerHourlyRate;
    private String freelancerAvatarUrl;
    private BigDecimal freelancerRating;
    private Integer freelancerCompletedJobs;
}
