package sdu.database.piedpiper.dto.response;

import lombok.Data;
import lombok.NoArgsConstructor;
import java.math.BigDecimal;
import java.util.List;

@Data
@NoArgsConstructor
public class FreelancerDashboardDTO {
    private BigDecimal totalEarnings;
    private int activeContracts;
    private int completedJobs;
    private int pendingProposals;
    private int totalProposalsSubmitted;
    private double averageRating;
    private double jobSuccessScore;
    private List<RecentActivityDTO> recentActivity;
}