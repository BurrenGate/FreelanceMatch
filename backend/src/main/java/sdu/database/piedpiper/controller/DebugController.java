package sdu.database.piedpiper.controller;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/debug")
public class DebugController {

    private final JdbcTemplate jdbc;

    public DebugController(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    @GetMapping("/check-schema")
    public Map<String, Object> checkSchema() {
        String sql = "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'skill_management'";
        List<Map<String, Object>> result = jdbc.queryForList(sql);
        return Map.of("schema_exists", !result.isEmpty(), "result", result);
    }

    @GetMapping("/check-function")
    public Map<String, Object> checkFunction() {
        String sql = "SELECT routine_name, routine_schema FROM information_schema.routines WHERE routine_schema = 'skill_management' AND routine_name = 'suggest_skill'";
        List<Map<String, Object>> result = jdbc.queryForList(sql);
        return Map.of("function_exists", !result.isEmpty(), "result", result);
    }

    @GetMapping("/flyway-status")
    public List<Map<String, Object>> flywayStatus() {
        String sql = "SELECT version, description, installed_on, success FROM flyway_schema_history WHERE version = '49' ORDER BY installed_rank DESC";
        return jdbc.queryForList(sql);
    }
}
