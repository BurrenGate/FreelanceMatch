package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.response.NotificationDTO;
import sdu.database.piedpiper.model.Notification;
import sdu.database.piedpiper.repository.NotificationRepositoryJdbc;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class NotificationService {

    private static final Logger log = LoggerFactory.getLogger(NotificationService.class);
    private final NotificationRepositoryJdbc notificationRepository;

    public NotificationService(NotificationRepositoryJdbc notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    /**
     * Get all unread notifications for a user
     */
    public List<NotificationDTO> getUnreadNotifications(Long accountId) {
        log.info("Fetching unread notifications for account {}", accountId);
        return notificationRepository.getUnreadNotifications(accountId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Get recent notifications for a user (last 50)
     */
    public List<NotificationDTO> getNotificationHistory(Long accountId) {
        log.info("Fetching notification history for account {}", accountId);
        return notificationRepository.getNotificationsByAccount(accountId)
                .stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    /**
     * Count unread notifications for a user
     */
    public Long countUnreadNotifications(Long accountId) {
        log.info("Counting unread notifications for account {}", accountId);
        return notificationRepository.countUnreadNotifications(accountId);
    }

    /**
     * Get a specific notification by ID
     */
    public NotificationDTO getNotificationById(Long id) {
        log.info("Fetching notification {}", id);
        Notification notification = notificationRepository.getNotificationById(id);
        if (notification == null) {
            throw new RuntimeException("Notification not found with id: " + id);
        }
        return mapToDTO(notification);
    }

    /**
     * Mark a notification as read
     */
    public void markAsRead(Long notificationId) {
        log.info("Marking notification {} as read", notificationId);
        notificationRepository.markAsRead(notificationId);
    }

    /**
     * Mark all notifications as read for a user
     */
    public void markAllAsRead(Long accountId) {
        log.info("Marking all notifications as read for account {}", accountId);
        notificationRepository.markAllAsRead(accountId);
    }

    /**
     * Map Notification entity to DTO
     */
    private NotificationDTO mapToDTO(Notification notification) {
        return NotificationDTO.builder()
                .id(notification.getId())
                .accountId(notification.getAccountId())
                .notificationType(notification.getNotificationType())
                .title(notification.getTitle())
                .message(notification.getMessage())
                .relatedEntityType(notification.getRelatedEntityType())
                .relatedEntityId(notification.getRelatedEntityId())
                .isRead(notification.getIsRead())
                .createdAt(notification.getCreatedAt())
                .readAt(notification.getReadAt())
                .build();
    }
}
