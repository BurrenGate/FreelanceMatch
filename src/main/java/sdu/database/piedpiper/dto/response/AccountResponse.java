package sdu.database.piedpiper.dto.response;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class AccountResponse {
    private Long id;
    private String email;
    private Integer roleId;
    private String roleName;
    private String status;
    private LocalDateTime lastLogin;
    private LocalDateTime createdAt;
}
