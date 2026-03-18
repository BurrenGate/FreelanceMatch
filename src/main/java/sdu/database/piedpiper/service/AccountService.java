package sdu.database.piedpiper.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import sdu.database.piedpiper.dto.request.RegisterRequest;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.repository.AccountRepository;

@Service
public class AccountService {

    private static final Logger log = LoggerFactory.getLogger(AccountService.class);
    private final AccountRepository accountRepository;
    private final PasswordEncoder passwordEncoder;

    public AccountService(AccountRepository accountRepository, PasswordEncoder passwordEncoder) {
        this.accountRepository = accountRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public void registerAccount(RegisterRequest request) {
        log.info("Attempting to register user with email: {}", request.getEmail());

        // Хешируем пароль перед отправкой в базу с помощью BCrypt
        String encodedPassword = passwordEncoder.encode(request.getPassword());

        // Вся транзакционная логика происходит внутри PL/pgSQL процедуры
        accountRepository.registerUser(
                request.getEmail(),
                encodedPassword,
                request.getRoleId(),
                request.getFirstName(),
                request.getLastName(),
                request.getHourlyRate()
        );

        log.info("User {} successfully registered", request.getEmail());
    }

    // Метод логина мы удалили! Теперь за проверку паролей отвечает
    // AuthenticationManager в твоем AuthController.

    // Этот метод нужен контроллеру и Security, чтобы доставать юзера из БД
    public Account findByEmail(String email) {
        log.debug("Fetching account by email: {}", email);
        return accountRepository.findByEmail(email);
    }
}