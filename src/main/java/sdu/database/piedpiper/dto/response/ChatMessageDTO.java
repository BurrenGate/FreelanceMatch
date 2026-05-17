package sdu.database.piedpiper.dto.response;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatMessageDTO {
    private Long messageId;
    private Long senderId;
    private String senderName;
    private String messageText;
    private String fileObjectName;
    private String fileUrl;
    private String fileType;
    private Long fileSize;
    private Boolean isRead;
    private LocalDateTime createdAt;
}
