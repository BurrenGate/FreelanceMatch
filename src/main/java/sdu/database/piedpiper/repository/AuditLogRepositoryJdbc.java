package sdu.database.piedpiper.repository;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.AuditLog;

import java.util.List;

@Repository
public class AuditLogRepositoryJdbc {

    private final JdbcTemplate jdbc;

    public AuditLogRepositoryJdbc(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<AuditLog> AUDIT_LOG_MAPPER = (rs, rowNum) -> {
        AuditLog a = new AuditLog();
        a.setId(rs.getLong("id"));
        a.setEntityType(rs.getString("entity_type"));
        a.setEntityId(rs.getLong("entity_id"));
        a.setAction(rs.getString("action"));
        a.setChangedBy(rs.getLong("changed_by"));
        a.setChangeSummary(rs.getString("change_summary"));
        a.setChangedAt(rs.getTimestamp("changed_at") != null ? rs.getTimestamp("changed_at").toLocalDateTime() : null);
        return a;
    };

    public List<AuditLog> getAuditLogByEntity(String entityType, Long entityId) {
        String sql = "SELECT * FROM audit_log WHERE entity_type = ? AND entity_id = ? ORDER BY changed_at DESC LIMIT 100";
        return jdbc.query(sql, AUDIT_LOG_MAPPER, entityType, entityId);
    }

    public List<AuditLog> getAuditLogByType(String entityType) {
        String sql = "SELECT * FROM audit_log WHERE entity_type = ? ORDER BY changed_at DESC LIMIT 100";
        return jdbc.query(sql, AUDIT_LOG_MAPPER, entityType);
    }

    public List<AuditLog> getAuditLogByAction(String action) {
        String sql = "SELECT * FROM audit_log WHERE action = ? ORDER BY changed_at DESC LIMIT 100";
        return jdbc.query(sql, AUDIT_LOG_MAPPER, action);
    }

    public AuditLog getAuditLogById(Long id) {
        String sql = "SELECT * FROM audit_log WHERE id = ?";
        List<AuditLog> result = jdbc.query(sql, AUDIT_LOG_MAPPER, id);
        return result.isEmpty() ? null : result.get(0);
    }
}
