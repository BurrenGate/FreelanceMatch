package sdu.database.piedpiper.controller;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/debug")
public class DebugClientController {

    private final JdbcTemplate jdbc;

    public DebugClientController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping("/test-client-function/{clientId}")
    public Map<String, Object> testClientFunction(@PathVariable Long clientId) {
        try {
            String sql = "SELECT * FROM job_market.get_client_profile(?)";
            List<Map<String, Object>> result = jdbc.queryForList(sql, clientId);
            return Map.of("success", true, "result", result);
        } catch (Exception e) {
            return Map.of("success", false, "error", e.getMessage(), "cause", e.getCause() != null ? e.getCause().getMessage() : "null");
        }
    }
}
