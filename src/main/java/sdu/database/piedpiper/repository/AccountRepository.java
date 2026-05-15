package sdu.database.piedpiper.repository;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;
import sdu.database.piedpiper.dto.response.AccountResponse;
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
        a.setLastLogin(rs.getTimestamp("last_login") != null ? rs.getTimestamp("last_login").toLocalDateTime() : null);
        a.setCreatedAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null);
        return a;
    };

    private static final RowMapper<AccountResponse> ACCOUNT_RESPONSE_MAPPER = (rs, rowNum) -> AccountResponse.builder()
            .id(rs.getLong("id"))
            .email(rs.getString("email"))
            .roleId(rs.getInt("role_id"))
            .roleName(rs.getString("role_name"))
            .status(rs.getString("status"))
            .lastLogin(rs.getTimestamp("last_login") != null ? rs.getTimestamp("last_login").toLocalDateTime() : null)
            .createdAt(rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null)
            .build();

    public void registerUser(String email, String passwordHash, Integer roleId, 
                             String firstName, String lastName, java.math.BigDecimal hourlyRate) {
        log.debug("Calling register_user procedure for email: {}", email);
        String sql = "CALL user_management.register_user(?, ?, ?, ?, ?, ?)";
        jdbc.update(sql, email, passwordHash, roleId, firstName, lastName, hourlyRate);
    }

    public Account findByEmail(String email) {
        String sql = "SELECT * FROM accounts WHERE email = ?";
        List<Account> accounts = jdbc.query(sql, ACCOUNT_MAPPER, email);
        return accounts.isEmpty() ? null : accounts.get(0);
    }

    public void registerUserWithRole(String email, String passwordHash, Integer roleId, 
                                       String firstName, String lastName, java.math.BigDecimal hourlyRate) {
        log.debug("Calling job_market.register_user procedure for email: {}", email);
        String sql = "CALL job_market.register_user(?, ?, ?, ?, ?, ?)";
        jdbc.update(sql, email, passwordHash, roleId, firstName, lastName, hourlyRate);
    }

    public List<AccountResponse> getAccounts(String status, String adminEmail) {
        String sql = "SELECT * FROM admin_management.get_accounts(?, ?)";
        return jdbc.query(sql, ACCOUNT_RESPONSE_MAPPER, status, adminEmail);
    }

    public AccountResponse getAccountById(Long accountId, String adminEmail) {
        String sql = "SELECT * FROM admin_management.get_account_by_id(?, ?)";
        return jdbc.queryForObject(sql, ACCOUNT_RESPONSE_MAPPER, accountId, adminEmail);
    }

    public void updateAccountStatus(Long accountId, String status, String adminEmail) {
        String sql = "CALL admin_management.set_account_status(?, ?, ?)";
        jdbc.update(sql, accountId, status, adminEmail);
    }

    public void changePassword(String email, String oldPasswordHash, String newPasswordHash) {
        String sql = "SELECT account_management.change_password(?, ?, ?)";
        jdbc.queryForObject(sql, String.class, email, oldPasswordHash, newPasswordHash);
    }

    public void updateLastLogin(String email) {
        String sql = "SELECT account_management.update_last_login(?)";
        jdbc.queryForObject(sql, java.sql.Timestamp.class, email);
    }

    public void deactivateAccount(String email) {
        String sql = "SELECT account_management.deactivate_account(?)";
        jdbc.queryForObject(sql, String.class, email);
    }
}
