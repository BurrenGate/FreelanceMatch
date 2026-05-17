package sdu.database.piedpiper.controller;

import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.SendMessageRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.ChatConversationDTO;
import sdu.database.piedpiper.dto.response.ChatMessageDTO;
import sdu.database.piedpiper.dto.response.ChatPartnerDTO;
import sdu.database.piedpiper.service.ChatService;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private static final Logger log = LoggerFactory.getLogger(ChatController.class);
    private final ChatService chatService;

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
    }

    @PostMapping("/messages")
    public ResponseEntity<ApiResponse<Map<String, Long>>> sendMessage(@Valid @RequestBody SendMessageRequest request) {
        log.debug("POST /api/chat/messages");
        try {
            Long messageId = chatService.sendMessage(request);
            return ResponseEntity.status(HttpStatus.CREATED)
                    .body(ApiResponse.ok("Message sent successfully", Map.of("messageId", messageId)));
        } catch (IllegalArgumentException e) {
            log.error("Invalid message request: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(ApiResponse.error(e.getMessage()));
        } catch (Exception e) {
            log.error("Error sending message: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to send message: " + e.getMessage()));
        }
    }

    @GetMapping("/conversations")
    public ResponseEntity<ApiResponse<List<ChatConversationDTO>>> getUserConversations() {
        log.debug("GET /api/chat/conversations");
        try {
            List<ChatConversationDTO> conversations = chatService.getUserConversations();
            return ResponseEntity.ok(ApiResponse.ok(
                    conversations.isEmpty() ? "No conversations found" : "Retrieved " + conversations.size() + " conversation(s)",
                    conversations
            ));
        } catch (Exception e) {
            log.error("Error getting conversations: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to get conversations: " + e.getMessage()));
        }
    }

    @GetMapping("/conversations/{conversationId}/messages")
    public ResponseEntity<ApiResponse<List<ChatMessageDTO>>> getConversationMessages(
            @PathVariable Long conversationId,
            @RequestParam(required = false, defaultValue = "50") Integer limit,
            @RequestParam(required = false, defaultValue = "0") Integer offset) {
        log.debug("GET /api/chat/conversations/{}/messages", conversationId);
        try {
            List<ChatMessageDTO> messages = chatService.getConversationMessages(conversationId, limit, offset);
            return ResponseEntity.ok(ApiResponse.ok(
                    messages.isEmpty() ? "No messages found" : "Retrieved " + messages.size() + " message(s)",
                    messages
            ));
        } catch (Exception e) {
            log.error("Error getting messages: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to get messages: " + e.getMessage()));
        }
    }

    @PostMapping("/conversations/{conversationId}/read")
    public ResponseEntity<ApiResponse<Map<String, Integer>>> markMessagesAsRead(@PathVariable Long conversationId) {
        log.debug("POST /api/chat/conversations/{}/read", conversationId);
        try {
            Integer count = chatService.markMessagesAsRead(conversationId);
            return ResponseEntity.ok(ApiResponse.ok(
                    count + " message(s) marked as read",
                    Map.of("markedCount", count)
            ));
        } catch (Exception e) {
            log.error("Error marking messages as read: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to mark messages as read: " + e.getMessage()));
        }
    }

    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<Map<String, Integer>>> getUnreadCount() {
        log.debug("GET /api/chat/unread-count");
        try {
            Integer count = chatService.getUnreadCount();
            return ResponseEntity.ok(ApiResponse.ok(
                    "Unread count retrieved",
                    Map.of("unreadCount", count)
            ));
        } catch (Exception e) {
            log.error("Error getting unread count: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to get unread count: " + e.getMessage()));
        }
    }

    @GetMapping("/partners")
    public ResponseEntity<ApiResponse<List<ChatPartnerDTO>>> getAvailableChatPartners() {
        log.debug("GET /api/chat/partners");
        try {
            List<ChatPartnerDTO> partners = chatService.getAvailableChatPartners();
            return ResponseEntity.ok(ApiResponse.ok(
                    partners.isEmpty() ? "No chat partners available" : "Retrieved " + partners.size() + " partner(s)",
                    partners
            ));
        } catch (Exception e) {
            log.error("Error getting chat partners: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(ApiResponse.error("Failed to get chat partners: " + e.getMessage()));
        }
    }
}
