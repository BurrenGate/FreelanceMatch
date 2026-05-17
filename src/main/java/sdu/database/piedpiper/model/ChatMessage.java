package sdu.database.piedpiper.model;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessage {
    private Long id;
    private Long conversationId;
    private Long senderId;
    private String messageText;
    private String fileObjectName;
    private String fileUrl;
    private String fileType;
    private Long fileSize;
    private Boolean isRead;
    private LocalDateTime createdAt;
}
