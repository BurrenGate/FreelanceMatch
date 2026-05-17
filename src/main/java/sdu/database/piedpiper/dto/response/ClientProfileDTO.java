package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClientProfileDTO {
    private Long profileId;
    private Long accountId;
    private String email;
    private String firstName;
    private String lastName;
    private String fullName;
    private String bio;
    private String avatarUrl;
    private BigDecimal totalSpent;
    private Integer postedJobs;
    private Integer activeJobs;
    private Integer completedJobs;
    private Integer totalReviewsGiven;
    private BigDecimal averageRatingGiven;
    private LocalDateTime memberSince;
    private LocalDateTime lastLogin;
    private String accountStatus;
    private List<ClientJobDTO> recentJobs;
    private List<ClientReviewDTO> recentReviews;
}
