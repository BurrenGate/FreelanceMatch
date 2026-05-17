package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatConversationDTO {
    private Long conversationId;
    private Long contractId;
    private Long otherUserId;
    private String otherUserName;
    private String otherUserAvatar;
    private String lastMessageText;
    private LocalDateTime lastMessageAt;
    private Long unreadCount;
    private LocalDateTime createdAt;
}
