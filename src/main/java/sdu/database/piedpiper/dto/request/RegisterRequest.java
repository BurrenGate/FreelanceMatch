package sdu.database.piedpiper.dto.request;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class RegisterRequest {
    private String email;
    private String password;
    private Integer roleId; // 1 - client, 2 - freelancer
    private String firstName;
    private String lastName;
    private BigDecimal hourlyRate; // Может быть null для заказчика
}