package sdu.database.piedpiper.dto.request;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateMilestoneRequest {
    private String title;
    private String description;
    private BigDecimal amount;
    private LocalDate dueDate;
}
