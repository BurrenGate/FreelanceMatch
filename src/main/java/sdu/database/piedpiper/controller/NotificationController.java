package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.dto.response.NotificationDTO;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.repository.AccountRepository;
import sdu.database.piedpiper.security.SecurityUtils;
import sdu.database.piedpiper.service.NotificationService;

import java.util.List;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    private static final Logger log = LoggerFactory.getLogger(NotificationController.class);

    private final NotificationService notificationService;
    private final AccountRepository accountRepository;

    public NotificationController(NotificationService notificationService, AccountRepository accountRepository) {
        this.notificationService = notificationService;
        this.accountRepository = accountRepository;
    }

    /**
     * Get unread notifications for the current user
     */
    @GetMapping("/unread")
    public ResponseEntity<ApiResponse<List<NotificationDTO>>> getUnreadNotifications() {
        log.debug("GET /api/notifications/unread");
        String username = SecurityUtils.getCurrentUsername();
        Account account = accountRepository.findByEmail(username);
        
        if (account == null) {
            return ResponseEntity.ok(ApiResponse.error("User not found"));
        }

        List<NotificationDTO> notifications = notificationService.getUnreadNotifications(account.getId());
        return ResponseEntity.ok(ApiResponse.ok("Unread notifications retrieved", notifications));
    }

    /**
     * Get notification history (last 50 notifications)
     */
    @GetMapping("/history")
    public ResponseEntity<ApiResponse<List<NotificationDTO>>> getNotificationHistory() {
        log.debug("GET /api/notifications/history");
        String username = SecurityUtils.getCurrentUsername();
        Account account = accountRepository.findByEmail(username);
        
        if (account == null) {
            return ResponseEntity.ok(ApiResponse.error("User not found"));
        }

        List<NotificationDTO> notifications = notificationService.getNotificationHistory(account.getId());
        return ResponseEntity.ok(ApiResponse.ok("Notification history retrieved", notifications));
    }

    /**
     * Count unread notifications for the current user
     */
    @GetMapping("/unread-count")
    public ResponseEntity<ApiResponse<Long>> countUnreadNotifications() {
        log.debug("GET /api/notifications/unread-count");
        String username = SecurityUtils.getCurrentUsername();
        Account account = accountRepository.findByEmail(username);
        
        if (account == null) {
            return ResponseEntity.ok(ApiResponse.error("User not found"));
        }

        Long count = notificationService.countUnreadNotifications(account.getId());
        return ResponseEntity.ok(ApiResponse.ok("Unread count retrieved", count));
    }

    /**
     * Mark a notification as read
     */
    @PutMapping("/{id}/read")
    public ResponseEntity<ApiResponse<Void>> markAsRead(@PathVariable Long id) {
        log.debug("PUT /api/notifications/{}/read", id);
        notificationService.markAsRead(id);
        return ResponseEntity.ok(ApiResponse.ok("Notification marked as read", null));
    }

    /**
     * Mark all notifications as read for the current user
     */
    @PutMapping("/mark-all-read")
    public ResponseEntity<ApiResponse<Void>> markAllAsRead() {
        log.debug("PUT /api/notifications/mark-all-read");
        String username = SecurityUtils.getCurrentUsername();
        Account account = accountRepository.findByEmail(username);
        
        if (account == null) {
            return ResponseEntity.ok(ApiResponse.error("User not found"));
        }

        notificationService.markAllAsRead(account.getId());
        return ResponseEntity.ok(ApiResponse.ok("All notifications marked as read", null));
    }

    /**
     * Get a specific notification by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<NotificationDTO>> getNotificationById(@PathVariable Long id) {
        log.debug("GET /api/notifications/{}", id);
        try {
            NotificationDTO notification = notificationService.getNotificationById(id);
            return ResponseEntity.ok(ApiResponse.ok("Notification retrieved", notification));
        } catch (RuntimeException e) {
            return null;
//            ResponseEntity.ok(ApiResponse.error(e.getMessage())
        }
    }
}
