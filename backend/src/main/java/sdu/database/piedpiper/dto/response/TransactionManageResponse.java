package sdu.database.piedpiper.dto.response;

import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
public class TransactionManageResponse {
    private Long id;
    private Long contractId;
    private BigDecimal amount;
    private String type;
    private LocalDateTime createdAt;
}
