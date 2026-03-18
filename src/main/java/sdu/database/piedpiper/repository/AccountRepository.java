package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.model.Account;

import java.util.List;

@Repository
public class AccountRepository {

    private static final Logger log = LoggerFactory.getLogger(AccountRepository.class);
    private final JdbcTemplate jdbc;

    public AccountRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    private static final RowMapper<Account> ACCOUNT_MAPPER = (rs, rowNum) -> {
        Account a = new Account();
        a.setId(rs.getLong("id"));
        a.setEmail(rs.getString("email"));
        a.setPasswordHash(rs.getString("password_hash"));
        a.setRoleId(rs.getInt("role_id"));
        a.setStatus(rs.getString("status"));
        return a;
    };

    // Вызов нашей PL/pgSQL процедуры для регистрации
    public void registerUser(String email, String passwordHash, Integer roleId, 
                             String firstName, String lastName, java.math.BigDecimal hourlyRate) {
        log.debug("Calling register_user procedure for email: {}", email);
        String sql = "CALL register_user(?, ?, ?, ?, ?, ?)";
        jdbc.update(sql, email, passwordHash, roleId, firstName, lastName, hourlyRate);
    }

    // Метод для MVP "логина" (найти юзера по email)
    public Account findByEmail(String email) {
        String sql = "SELECT * FROM accounts WHERE email = ?";
        List<Account> accounts = jdbc.query(sql, ACCOUNT_MAPPER, email);
        return accounts.isEmpty() ? null : accounts.get(0);
    }
}