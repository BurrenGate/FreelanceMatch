package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SkillSuggestionDTO {
    private Long suggestionId;
    private String skillName;
    private String skillCategory;
    private String status;
    private Long suggestedById;
    private String suggestedByName;
    private String suggestedByEmail;
    private String adminComment;
    private Long reviewedById;
    private String reviewedByName;
    private LocalDateTime reviewedAt;
    private LocalDateTime createdAt;
}
