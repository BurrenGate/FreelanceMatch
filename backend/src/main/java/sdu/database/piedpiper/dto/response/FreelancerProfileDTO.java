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
public class FreelancerProfileDTO {
    private Long profileId;
    private Long accountId;
    private String email;
    private String firstName;
    private String lastName;
    private String fullName;
    private String bio;
    private BigDecimal hourlyRate;
    private String avatarUrl;
    private BigDecimal rating;
    private BigDecimal totalEarnings;
    private Integer completedJobs;
    private Integer activeJobs;
    private Integer totalReviews;
    private Boolean isAvailable;
    private LocalDateTime memberSince;
    private LocalDateTime lastLogin;
    private String accountStatus;
    private List<FreelancerSkillDTO> skills;
    private List<FreelancerReviewDTO> recentReviews;
}
