package sdu.database.piedpiper.model;

import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FreelancerMatch {
    private Long       profileId;
    private String     fullName;
    private BigDecimal hourlyRate;
    private String     email;
    private Double     matchPct;
    private Double     rating;
    private BigDecimal totalEarnings;
    private Integer    activeJobs;
    private Boolean    isAvailable;
}

