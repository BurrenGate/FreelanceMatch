package sdu.database.piedpiper.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatPartnerDTO {
    private Long partnerId;
    private String partnerName;
    private String partnerAvatar;
    private String partnerRole;
    private Long conversationId;
    private Boolean hasConversation;
}
