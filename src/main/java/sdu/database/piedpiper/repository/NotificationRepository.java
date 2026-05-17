package sdu.database.piedpiper.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.Notification;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {

    /**
     * Find all notifications for a specific account
     */
    Page<Notification> findByAccountIdOrderByCreatedAtDesc(Long accountId, Pageable pageable);

    /**
     * Find unread notifications for a specific account
     */
    List<Notification> findByAccountIdAndIsReadFalseOrderByCreatedAtDesc(Long accountId);

    /**
     * Count unread notifications for a specific account
     */
    Long countByAccountIdAndIsReadFalse(Long accountId);

    /**
     * Find notifications by type for a specific account
     */
    Page<Notification> findByAccountIdAndNotificationTypeOrderByCreatedAtDesc(
        Long accountId,
        String notificationType,
        Pageable pageable
    );

    /**
     * Find notifications related to a specific entity
     */
    Page<Notification> findByRelatedEntityTypeAndRelatedEntityIdOrderByCreatedAtDesc(
        String entityType,
        Long entityId,
        Pageable pageable
    );

    /**
     * Mark notification as read
     */
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = CURRENT_TIMESTAMP WHERE n.id = :id")
    void markAsRead(@Param("id") Long id);

    /**
     * Mark all notifications as read for an account
     */
    @Query("UPDATE Notification n SET n.isRead = true, n.readAt = CURRENT_TIMESTAMP WHERE n.accountId = :accountId AND n.isRead = false")
    void markAllAsRead(@Param("accountId") Long accountId);
}
