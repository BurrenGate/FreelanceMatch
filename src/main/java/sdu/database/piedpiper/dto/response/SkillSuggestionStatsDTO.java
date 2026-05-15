package sdu.database.piedpiper.dto.response;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SkillSuggestionStatsDTO {
    private Long totalSuggestions;
    private Long pendingSuggestions;
    private Long approvedSuggestions;
    private Long rejectedSuggestions;
    private Long suggestionsToday;
    private Long suggestionsThisWeek;
    private Long suggestionsThisMonth;
}
