package sdu.database.piedpiper.repository;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.AuditLog;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface AuditLogRepository extends JpaRepository<AuditLog, Long> {

    /**
     * Find audit logs for a specific entity
     */
    Page<AuditLog> findByEntityTypeAndEntityIdOrderByChangedAtDesc(
        String entityType,
        Long entityId,
        Pageable pageable
    );

    /**
     * Find all audit logs for an entity type
     */
    Page<AuditLog> findByEntityTypeOrderByChangedAtDesc(String entityType, Pageable pageable);

    /**
     * Find audit logs by action
     */
    Page<AuditLog> findByActionOrderByChangedAtDesc(String action, Pageable pageable);

    /**
     * Find audit logs changed by a specific user
     */
    Page<AuditLog> findByChangedByOrderByChangedAtDesc(Long changedBy, Pageable pageable);

    /**
     * Find audit logs within a date range
     */
    List<AuditLog> findByChangedAtBetweenOrderByChangedAtDesc(
        LocalDateTime startDate,
        LocalDateTime endDate
    );

    /**
     * Find audit logs for an entity within a date range
     */
    Page<AuditLog> findByEntityTypeAndEntityIdAndChangedAtBetweenOrderByChangedAtDesc(
        String entityType,
        Long entityId,
        LocalDateTime startDate,
        LocalDateTime endDate,
        Pageable pageable
    );
}
