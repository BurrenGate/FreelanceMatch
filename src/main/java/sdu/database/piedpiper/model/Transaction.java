package sdu.database.piedpiper.model;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class Transaction {
    private Long id;
    private Long contractId;
    private BigDecimal amount;
    private String type;
    private LocalDateTime createdAt;
}

