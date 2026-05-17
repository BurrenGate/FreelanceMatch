package sdu.database.piedpiper.dto.response;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class AuditLogDTO {
    private Long id;
    private String entityType;
    private Long entityId;
    private String action;
    private Long changedBy;
    private Map<String, Object> oldValue;
    private Map<String, Object> newValue;
    private String changeSummary;
    private LocalDateTime changedAt;
}
