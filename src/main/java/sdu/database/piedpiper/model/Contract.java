package sdu.database.piedpiper.model;

import lombok.*;

import java.math.BigDecimal;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class Contract {
    private Long id;
    private Long jobId;
    private Long freelancerId;
    private BigDecimal totalAmount;
    private String status;
}
