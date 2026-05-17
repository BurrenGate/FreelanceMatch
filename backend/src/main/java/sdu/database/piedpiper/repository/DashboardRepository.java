package sdu.database.piedpiper.repository;

import com.fasterxml.jackson.core.JsonProcessingException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.FreelancerDashboardDTO;
import com.fasterxml.jackson.databind.ObjectMapper;

@Repository
public class DashboardRepository {

    private final JdbcTemplate jdbcTemplate;
    private final ObjectMapper objectMapper;

    public DashboardRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        this.objectMapper = new ObjectMapper();
    }

    public FreelancerDashboardDTO getDashboardByFreelancerId(Long freelancerId) throws JsonProcessingException {
        // Вызываем нашу PL/pgSQL функцию
        String sql = "SELECT get_freelancer_dashboard(?)";

        // Получаем результат в виде JSON строки
        String jsonResult = jdbcTemplate.queryForObject(sql, String.class, freelancerId);

        if (jsonResult == null) {
            return new FreelancerDashboardDTO();
        }

        // Конвертируем JSON строку напрямую в Java DTO
        return objectMapper.readValue(jsonResult, FreelancerDashboardDTO.class);
    }
}
