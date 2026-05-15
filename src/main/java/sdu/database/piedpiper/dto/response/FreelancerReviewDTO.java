package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FreelancerReviewDTO {
    private Long reviewId;
    private Long contractId;
    private String jobTitle;
    private String reviewerName;
    private Integer rating;
    private String comment;
    private LocalDateTime reviewDate;
}
