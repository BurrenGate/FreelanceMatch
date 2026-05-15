package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.ChatConversationDTO;
import sdu.database.piedpiper.dto.response.ChatMessageDTO;

import java.util.List;

@Repository
public class ChatRepository {

    private static final Logger log = LoggerFactory.getLogger(ChatRepository.class);
    private final JdbcTemplate jdbc;

    public ChatRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<ChatMessageDTO> MESSAGE_MAPPER = (rs, rowNum) -> {
        ChatMessageDTO dto = new ChatMessageDTO();
        dto.setMessageId(rs.getLong("message_id"));
        dto.setSenderId(rs.getLong("sender_id"));
        dto.setSenderName(rs.getString("sender_name"));
        dto.setMessageText(rs.getString("message_text"));
        dto.setFileObjectName(rs.getString("file_object_name"));
        dto.setFileUrl(rs.getString("file_url"));
        dto.setFileType(rs.getString("file_type"));
        Long fileSize = rs.getLong("file_size");
        dto.setFileSize(rs.wasNull() ? null : fileSize);
        dto.setIsRead(rs.getBoolean("is_read"));
        dto.setCreatedAt(rs.getTimestamp("created_at") != null
                ? rs.getTimestamp("created_at").toLocalDateTime()
                : null);
        return dto;
    };

    private static final RowMapper<ChatConversationDTO> CONVERSATION_MAPPER = (rs, rowNum) -> {
        ChatConversationDTO dto = new ChatConversationDTO();
        dto.setConversationId(rs.getLong("conversation_id"));
        Long contractId = rs.getLong("contract_id");
        dto.setContractId(rs.wasNull() ? null : contractId);
        dto.setOtherUserId(rs.getLong("other_user_id"));
        dto.setOtherUserName(rs.getString("other_user_name"));
        dto.setOtherUserAvatar(rs.getString("other_user_avatar"));
        dto.setLastMessageText(rs.getString("last_message_text"));
        dto.setLastMessageAt(rs.getTimestamp("last_message_at") != null
                ? rs.getTimestamp("last_message_at").toLocalDateTime()
                : null);
        dto.setUnreadCount(rs.getLong("unread_count"));
        dto.setCreatedAt(rs.getTimestamp("created_at") != null
                ? rs.getTimestamp("created_at").toLocalDateTime()
                : null);
        return dto;
    };

    public Long getOrCreateConversation(Long contractId, Long clientId, Long freelancerId) {
        log.debug("Calling get_or_create_conversation for contract {}, client {}, freelancer {}",
                contractId, clientId, freelancerId);
        String sql = "SELECT chat_management.get_or_create_conversation(?, ?, ?)";
        return jdbc.queryForObject(sql, Long.class, contractId, clientId, freelancerId);
    }

    public Long sendMessage(Long conversationId, Long senderId, String messageText,
                            String fileObjectName, String fileUrl, String fileType, Long fileSize) {
        log.debug("Calling send_message for conversation {}, sender {}", conversationId, senderId);
        String sql = "SELECT chat_management.send_message(?, ?, ?, ?, ?, ?, ?)";
        return jdbc.queryForObject(sql, Long.class,
                conversationId, senderId, messageText, fileObjectName, fileUrl, fileType, fileSize);
    }

    public List<ChatMessageDTO> getConversationMessages(Long conversationId, Long userId,
                                                        Integer limit, Integer offset) {
        log.debug("Calling get_conversation_messages for conversation {}, user {}", conversationId, userId);
        String sql = "SELECT message_id, sender_id, sender_name, message_text, file_object_name, " +
                     "file_url, file_type, file_size, is_read, created_at " +
                     "FROM chat_management.get_conversation_messages(?, ?, ?, ?)";
        return jdbc.query(sql, MESSAGE_MAPPER, conversationId, userId, limit, offset);
    }

    public List<ChatConversationDTO> getUserConversations(Long userId) {
        log.debug("Calling get_user_conversations for user {}", userId);
        String sql = "SELECT conversation_id, contract_id, other_user_id, other_user_name, " +
                     "other_user_avatar, last_message_text, last_message_at, unread_count, created_at " +
                     "FROM chat_management.get_user_conversations(?)";
        return jdbc.query(sql, CONVERSATION_MAPPER, userId);
    }

    public Integer markMessagesAsRead(Long conversationId, Long userId) {
        log.debug("Calling mark_messages_as_read for conversation {}, user {}", conversationId, userId);
        String sql = "SELECT chat_management.mark_messages_as_read(?, ?)";
        return jdbc.queryForObject(sql, Integer.class, conversationId, userId);
    }

    public Integer getUnreadCount(Long userId) {
        log.debug("Calling get_unread_count for user {}", userId);
        String sql = "SELECT chat_management.get_unread_count(?)";
        return jdbc.queryForObject(sql, Integer.class, userId);
    }

    public List<sdu.database.piedpiper.dto.response.ChatPartnerDTO> getAvailableChatPartners(Long userId) {
        log.debug("Calling get_available_chat_partners for user {}", userId);
        String sql = "SELECT partner_id, partner_name, partner_avatar, partner_role, " +
                     "conversation_id, has_conversation " +
                     "FROM chat_management.get_available_chat_partners(?)";
        return jdbc.query(sql, (rs, rowNum) -> {
            sdu.database.piedpiper.dto.response.ChatPartnerDTO dto = new sdu.database.piedpiper.dto.response.ChatPartnerDTO();
            dto.setPartnerId(rs.getLong("partner_id"));
            dto.setPartnerName(rs.getString("partner_name"));
            dto.setPartnerAvatar(rs.getString("partner_avatar"));
            dto.setPartnerRole(rs.getString("partner_role"));
            Long conversationId = rs.getLong("conversation_id");
            dto.setConversationId(rs.wasNull() ? null : conversationId);
            dto.setHasConversation(rs.getBoolean("has_conversation"));
            return dto;
        }, userId);
    }
}
