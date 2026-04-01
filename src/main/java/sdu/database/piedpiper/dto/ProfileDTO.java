package sdu.database.piedpiper.dto;

import lombok.Data;
import java.util.List;

@Data
public class ProfileDTO {
    private Long id;
    private String username;
    private String email;
    private Double rating;
    private Double balance;
    private List<String> skills;
}
