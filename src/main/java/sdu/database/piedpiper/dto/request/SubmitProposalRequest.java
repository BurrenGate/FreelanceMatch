package sdu.database.piedpiper.dto.request;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class SubmitProposalRequest {
    private Long jobId;
    private Long freelancerId;
    private BigDecimal bidAmount;
    private String coverLetter;
}