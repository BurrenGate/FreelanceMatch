package sdu.database.piedpiper.dto.request;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class SendMessageRequest {
    private Long conversationId;
    private Long contractId;
    private Long recipientId;
    private String messageText;
    private String fileObjectName;
    private String fileUrl;
    private String fileType;
    private Long fileSize;
}
