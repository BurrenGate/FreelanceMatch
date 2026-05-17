package sdu.database.piedpiper.model;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatConversation {
    private Long id;
    private Long contractId;
    private Long clientId;
    private Long freelancerId;
    private LocalDateTime lastMessageAt;
    private LocalDateTime createdAt;
}
