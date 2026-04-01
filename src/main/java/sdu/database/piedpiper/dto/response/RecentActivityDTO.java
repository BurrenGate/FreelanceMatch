package sdu.database.piedpiper.dto.response;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
public class RecentActivityDTO {
    private String activityType;
    private String title;
    private String status;
    private BigDecimal amount;
    private LocalDateTime date;
}