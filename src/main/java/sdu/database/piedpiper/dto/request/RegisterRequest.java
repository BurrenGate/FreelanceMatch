package sdu.database.piedpiper.dto.request;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class RegisterRequest {
    private String email;
    private String password;
    private Integer roleId;
    private String firstName;
    private String lastName;
    private BigDecimal hourlyRate;
}