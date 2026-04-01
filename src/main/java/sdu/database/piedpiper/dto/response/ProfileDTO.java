package sdu.database.piedpiper.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ProfileDTO {

    // --- Данные из таблицы accounts ---
    private Long accountId;
    private String email;
    private String role;          // Сюда будем мапить name из таблицы roles (client, freelancer, admin)
    private String accountStatus; // active, etc.
    private LocalDateTime lastLogin;
    private LocalDateTime accountCreatedAt;

    // --- Данные из таблицы profiles ---
    private Long profileId;
    private String firstName;
    private String lastName;
    private String bio;
    private BigDecimal hourlyRate;
    private String avatarUrl;
    private LocalDateTime profileUpdatedAt;

    // --- Расчетные (агрегированные) данные ---
    // Рейтинг высчитывается как AVG(rating) из таблицы reviews
    private Double rating;
    // Баланс высчитывается как SUM(amount) из таблицы transactions
    private BigDecimal balance;

    // --- Связанные данные ---
    private List<ProfileSkillDetailedDTO> skills;
}