package sdu.database.piedpiper.model;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class Profile {
    private Long id;
    private Long accountId;
    private String firstName;
    private String lastName;
    private String bio;
    private java.math.BigDecimal hourlyRate;
    private String avatarUrl;
    private LocalDateTime updatedAt;
}
