package sdu.database.piedpiper.dto.response;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class UpdateProfileDTO {
    private String firstName;
    private String lastName;
    private String bio;
    private BigDecimal hourlyRate;
    private String avatarUrl;
}