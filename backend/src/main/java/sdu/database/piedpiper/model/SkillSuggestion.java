package sdu.database.piedpiper.model;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SkillSuggestion {
    private Long id;
    private String name;
    private String category;
    private Long suggestedBy;
    private String status; // pending, approved, rejected
    private String adminComment;
    private Long reviewedBy;
    private LocalDateTime reviewedAt;
    private LocalDateTime createdAt;
}
