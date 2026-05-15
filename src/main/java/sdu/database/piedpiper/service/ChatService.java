package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.SendMessageRequest;
import sdu.database.piedpiper.dto.response.ChatConversationDTO;
import sdu.database.piedpiper.dto.response.ChatMessageDTO;
import sdu.database.piedpiper.exception.ForbiddenOperationException;
import sdu.database.piedpiper.exception.NotFoundException;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.model.Profile;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.repository.ChatRepository;
import sdu.database.piedpiper.repository.ProfileRepository;
import sdu.database.piedpiper.security.SecurityUtils;

import java.util.List;

@Service
public class ChatService {

    private static final Logger log = LoggerFactory.getLogger(ChatService.class);
    private final ChatRepository chatRepository;
    private final AccountRepository accountRepository;
    private final ProfileRepository profileRepository;

    public ChatService(ChatRepository chatRepository,
                       AccountRepository accountRepository,
                       ProfileRepository profileRepository) {
        this.chatRepository = chatRepository;
        this.accountRepository = accountRepository;
        this.profileRepository = profileRepository;
    }

    public Long sendMessage(SendMessageRequest request) {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }

        Account account = accountRepository.findByEmail(email);
        if (account == null) {
            throw new NotFoundException("Account not found");
        }

        Profile senderProfile = profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found"));

        Long senderId = senderProfile.getId();
        Long conversationId = request.getConversationId();

        // If conversation doesn't exist, create it
        if (conversationId == null) {
            if (request.getContractId() == null || request.getRecipientId() == null) {
                throw new IllegalArgumentException("Contract ID and Recipient ID are required for new conversation");
            }

            // Determine client and freelancer IDs
            Profile recipientProfile = profileRepository.findById(request.getRecipientId())
                    .orElseThrow(() -> new NotFoundException("Recipient profile not found"));

            Account senderAccount = accountRepository.findByEmail(email);
            Account recipientAccount = accountRepository.findByEmail(
                    profileRepository.findById(request.getRecipientId())
                            .map(p -> accountRepository.findByEmail(email))
                            .map(Account::getEmail)
                            .orElse(null)
            );

            Long clientId, freelancerId;
            if (senderAccount.getRoleId() == 1) { // sender is client
                clientId = senderId;
                freelancerId = request.getRecipientId();
            } else { // sender is freelancer
                clientId = request.getRecipientId();
                freelancerId = senderId;
            }

            conversationId = chatRepository.getOrCreateConversation(
                    request.getContractId(), clientId, freelancerId);
        }

        // Validate message content
        if ((request.getMessageText() == null || request.getMessageText().trim().isEmpty())
                && request.getFileObjectName() == null) {
            throw new IllegalArgumentException("Message must contain text or file");
        }

        log.info("User {} sending message to conversation {}", senderId, conversationId);

        return chatRepository.sendMessage(
                conversationId,
                senderId,
                request.getMessageText(),
                request.getFileObjectName(),
                request.getFileUrl(),
                request.getFileType(),
                request.getFileSize()
        );
    }

    public List<ChatMessageDTO> getConversationMessages(Long conversationId, Integer limit, Integer offset) {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }

        Account account = accountRepository.findByEmail(email);
        Profile profile = profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found"));

        log.info("User {} fetching messages from conversation {}", profile.getId(), conversationId);

        return chatRepository.getConversationMessages(
                conversationId,
                profile.getId(),
                limit != null ? limit : 50,
                offset != null ? offset : 0
        );
    }

    public List<ChatConversationDTO> getUserConversations() {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }

        Account account = accountRepository.findByEmail(email);
        Profile profile = profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found"));

        log.info("User {} fetching conversations", profile.getId());

        return chatRepository.getUserConversations(profile.getId());
    }

    public Integer markMessagesAsRead(Long conversationId) {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }

        Account account = accountRepository.findByEmail(email);
        Profile profile = profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found"));

        log.info("User {} marking messages as read in conversation {}", profile.getId(), conversationId);

        return chatRepository.markMessagesAsRead(conversationId, profile.getId());
    }

    public Integer getUnreadCount() {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }

        Account account = accountRepository.findByEmail(email);
        Profile profile = profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found"));

        return chatRepository.getUnreadCount(profile.getId());
    }

    public List<sdu.database.piedpiper.dto.response.ChatPartnerDTO> getAvailableChatPartners() {
        String email = SecurityUtils.getCurrentUsername();
        if (email == null) {
            throw new ForbiddenOperationException("User is not authenticated");
        }

        Account account = accountRepository.findByEmail(email);
        Profile profile = profileRepository.findByAccountId(account.getId())
                .orElseThrow(() -> new NotFoundException("Profile not found"));

        log.info("User {} fetching available chat partners", profile.getId());

        return chatRepository.getAvailableChatPartners(profile.getId());
    }
}
