package sdu.database.piedpiper.model;

import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@NoArgsConstructor @AllArgsConstructor
public class Account {
    private Long id;
    private String email;
    private String passwordHash;
    private Integer roleId;
    private String status;
    private LocalDateTime lastLogin;
    private LocalDateTime createdAt;
}

