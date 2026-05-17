package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MySkillSuggestionDTO {
    private Long suggestionId;
    private String skillName;
    private String skillCategory;
    private String status;
    private String adminComment;
    private String reviewedByName;
    private LocalDateTime reviewedAt;
    private LocalDateTime createdAt;
}
