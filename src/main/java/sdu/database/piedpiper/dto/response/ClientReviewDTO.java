package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ClientReviewDTO {
    private Long reviewId;
    private Long contractId;
    private String jobTitle;
    private String freelancerName;
    private Integer rating;
    private String comment;
    private LocalDateTime createdAt;
}
