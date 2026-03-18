package sdu.database.piedpiper.dto.request;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class CompleteJobRequest {
    private Long contractId;
    private BigDecimal rating;
    private String feedback;
}