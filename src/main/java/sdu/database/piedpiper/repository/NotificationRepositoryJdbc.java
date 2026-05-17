package sdu.database.piedpiper.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.Notification;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

@Repository
public class NotificationRepositoryJdbc {

    private final JdbcTemplate jdbc;

    public NotificationRepositoryJdbc(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<Notification> NOTIFICATION_MAPPER = (rs, rowNum) -> {
        Notification n = new Notification();
        n.setId(rs.getLong("id"));
        n.setAccountId(rs.getLong("account_id"));
        n.setNotificationType(rs.getString("notification_type"));
        n.setTitle(rs.getString("title"));
        n.setMessage(rs.getString("message"));
        n.setRelatedEntityType(rs.getString("related_entity_type"));
        n.setRelatedEntityId(rs.getLong("related_entity_id"));
        n.setIsRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null);
        n.setReadAt(rs.getTimestamp("read_at") != null ? rs.getTimestamp("read_at").toLocalDateTime() : null);
        return n;
    };

    public List<Notification> getUnreadNotifications(Long accountId) {
        String sql = "SELECT * FROM notifications WHERE account_id = ? AND is_read = FALSE ORDER BY created_at DESC";
        return jdbc.query(sql, NOTIFICATION_MAPPER, accountId);
    }

    public List<Notification> getNotificationsByAccount(Long accountId) {
        String sql = "SELECT * FROM notifications WHERE account_id = ? ORDER BY created_at DESC LIMIT 50";
        return jdbc.query(sql, NOTIFICATION_MAPPER, accountId);
    }

    public Long countUnreadNotifications(Long accountId) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE account_id = ? AND is_read = FALSE";
        Long count = jdbc.queryForObject(sql, Long.class, accountId);
        return count != null ? count : 0;
    }

    public Notification getNotificationById(Long id) {
        String sql = "SELECT * FROM notifications WHERE id = ?";
        List<Notification> result = jdbc.query(sql, NOTIFICATION_MAPPER, id);
        return result.isEmpty() ? null : result.get(0);
    }

    public void markAsRead(Long notificationId) {
        String sql = "UPDATE notifications SET is_read = TRUE, read_at = NOW() WHERE id = ?";
        jdbc.update(sql, notificationId);
    }

    public void markAllAsRead(Long accountId) {
        String sql = "UPDATE notifications SET is_read = TRUE, read_at = NOW() WHERE account_id = ? AND is_read = FALSE";
        jdbc.update(sql, accountId);
    }
}
