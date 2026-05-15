package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.MySkillSuggestionDTO;
import sdu.database.piedpiper.dto.response.SkillSuggestionDTO;
import sdu.database.piedpiper.dto.response.SkillSuggestionStatsDTO;

import java.util.List;
import java.util.Map;

@Repository
public class SkillSuggestionRepository {

    private static final Logger log = LoggerFactory.getLogger(SkillSuggestionRepository.class);
    private final JdbcTemplate jdbc;

    public SkillSuggestionRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<SkillSuggestionDTO> SUGGESTION_MAPPER = (rs, rowNum) -> {
        SkillSuggestionDTO dto = new SkillSuggestionDTO();
        dto.setSuggestionId(rs.getLong("suggestion_id"));
        dto.setSkillName(rs.getString("skill_name"));
        dto.setSkillCategory(rs.getString("skill_category"));
        dto.setStatus(rs.getString("status"));
        dto.setSuggestedById(rs.getLong("suggested_by_id"));
        dto.setSuggestedByName(rs.getString("suggested_by_name"));
        dto.setSuggestedByEmail(rs.getString("suggested_by_email"));
        dto.setAdminComment(rs.getString("admin_comment"));
        Long reviewedById = rs.getLong("reviewed_by_id");
        dto.setReviewedById(rs.wasNull() ? null : reviewedById);
        dto.setReviewedByName(rs.getString("reviewed_by_name"));
        dto.setReviewedAt(rs.getTimestamp("reviewed_at") != null
                ? rs.getTimestamp("reviewed_at").toLocalDateTime()
                : null);
        dto.setCreatedAt(rs.getTimestamp("created_at") != null
                ? rs.getTimestamp("created_at").toLocalDateTime()
                : null);
        return dto;
    };

    private static final RowMapper<MySkillSuggestionDTO> MY_SUGGESTION_MAPPER = (rs, rowNum) -> {
        MySkillSuggestionDTO dto = new MySkillSuggestionDTO();
        dto.setSuggestionId(rs.getLong("suggestion_id"));
        dto.setSkillName(rs.getString("skill_name"));
        dto.setSkillCategory(rs.getString("skill_category"));
        dto.setStatus(rs.getString("status"));
        dto.setAdminComment(rs.getString("admin_comment"));
        dto.setReviewedByName(rs.getString("reviewed_by_name"));
        dto.setReviewedAt(rs.getTimestamp("reviewed_at") != null
                ? rs.getTimestamp("reviewed_at").toLocalDateTime()
                : null);
        dto.setCreatedAt(rs.getTimestamp("created_at") != null
                ? rs.getTimestamp("created_at").toLocalDateTime()
                : null);
        return dto;
    };

    public Map<String, Object> suggestSkill(String name, String category, Long userId) {
        log.debug("Calling suggest_skill for user {}: {} ({})", userId, name, category);
        try {
            return jdbc.execute((java.sql.Connection conn) -> {
                String sql = "SELECT * FROM skill_management.suggest_skill(?, ?, ?)";
                try (java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name);
                    ps.setString(2, category);
                    ps.setLong(3, userId);
                    
                    try (java.sql.ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            Map<String, Object> map = new java.util.HashMap<>();
                            map.put("suggestion_id", rs.getLong("suggestion_id"));
                            map.put("skill_name", rs.getString("skill_name"));
                            map.put("skill_category", rs.getString("skill_category"));
                            map.put("status", rs.getString("status"));
                            map.put("message", rs.getString("message"));
                            return map;
                        }
                        return null;
                    }
                }
            });
        } catch (Exception e) {
            log.error("Error calling suggest_skill: {}", e.getMessage(), e);
            throw new RuntimeException("Failed to suggest skill: " + e.getMessage(), e);
        }
    }

    public List<SkillSuggestionDTO> getSkillSuggestions(Long adminId, String status) {
        log.debug("Calling get_skill_suggestions for admin {}, status: {}", adminId, status);
        String sql = "SELECT * FROM skill_management.get_skill_suggestions(?, ?)";
        return jdbc.query(sql, SUGGESTION_MAPPER, adminId, status);
    }

    public List<MySkillSuggestionDTO> getMySkillSuggestions(Long userId) {
        log.debug("Calling get_my_skill_suggestions for user {}", userId);
        String sql = "SELECT * FROM skill_management.get_my_skill_suggestions(?)";
        return jdbc.query(sql, MY_SUGGESTION_MAPPER, userId);
    }

    public Map<String, Object> approveSkillSuggestion(Long suggestionId, Long adminId, String adminComment) {
        log.debug("Calling approve_skill_suggestion: suggestion {}, admin {}", suggestionId, adminId);
        String sql = "SELECT * FROM skill_management.approve_skill_suggestion(?, ?, ?)";
        List<Map<String, Object>> results = jdbc.query(sql, (rs, rowNum) -> {
            Map<String, Object> map = new java.util.HashMap<>();
            map.put("skill_id", rs.getInt("skill_id"));
            map.put("skill_name", rs.getString("skill_name"));
            map.put("skill_category", rs.getString("skill_category"));
            map.put("message", rs.getString("message"));
            return map;
        }, suggestionId, adminId, adminComment);
        return results.isEmpty() ? null : results.get(0);
    }

    public Map<String, Object> rejectSkillSuggestion(Long suggestionId, Long adminId, String adminComment) {
        log.debug("Calling reject_skill_suggestion: suggestion {}, admin {}", suggestionId, adminId);
        String sql = "SELECT * FROM skill_management.reject_skill_suggestion(?, ?, ?)";
        List<Map<String, Object>> results = jdbc.query(sql, (rs, rowNum) -> {
            Map<String, Object> map = new java.util.HashMap<>();
            map.put("suggestion_id", rs.getLong("suggestion_id"));
            map.put("skill_name", rs.getString("skill_name"));
            map.put("status", rs.getString("status"));
            map.put("message", rs.getString("message"));
            return map;
        }, suggestionId, adminId, adminComment);
        return results.isEmpty() ? null : results.get(0);
    }

    public SkillSuggestionStatsDTO getSuggestionStatistics(Long adminId) {
        log.debug("Calling get_suggestion_statistics for admin {}", adminId);
        String sql = "SELECT * FROM skill_management.get_suggestion_statistics(?)";
        return jdbc.queryForObject(sql, (rs, rowNum) -> {
            SkillSuggestionStatsDTO stats = new SkillSuggestionStatsDTO();
            stats.setTotalSuggestions(rs.getLong("total_suggestions"));
            stats.setPendingSuggestions(rs.getLong("pending_suggestions"));
            stats.setApprovedSuggestions(rs.getLong("approved_suggestions"));
            stats.setRejectedSuggestions(rs.getLong("rejected_suggestions"));
            stats.setSuggestionsToday(rs.getLong("suggestions_today"));
            stats.setSuggestionsThisWeek(rs.getLong("suggestions_this_week"));
            stats.setSuggestionsThisMonth(rs.getLong("suggestions_this_month"));
            return stats;
        }, adminId);
    }
}
