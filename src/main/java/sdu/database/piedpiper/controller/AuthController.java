package sdu.database.piedpiper.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.*;
import sdu.database.piedpiper.dto.request.LoginRequest;
import sdu.database.piedpiper.dto.request.RegisterRequest;
import sdu.database.piedpiper.dto.response.ApiResponse;
import sdu.database.piedpiper.model.Account;
import sdu.database.piedpiper.security.JwtUtil;
import sdu.database.piedpiper.service.AccountService;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final AccountService accountService;
    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    public AuthController(AuthenticationManager authenticationManager, JwtUtil jwtUtil, AccountService accountService) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.accountService = accountService;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<Void>> register(@RequestBody RegisterRequest request) {
        logger.info("Registering user: {}", request.getEmail());
        try {
            accountService.registerAccount(request);
            logger.info("User registered successfully: {}", request.getEmail());
            return ResponseEntity.ok(ApiResponse.ok("Пользователь успешно зарегистрирован!", null));
        } catch (Exception e) {
            logger.error("Error registering user: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<String>> login(@RequestBody LoginRequest request) {
        logger.info("Login attempt for user: {}", request.getEmail());
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );

            Account account = accountService.findByEmail(request.getEmail());

            String token = jwtUtil.generateToken(account.getEmail(), account.getRoleId());
            logger.info("Login successful for user: {}", request.getEmail());

            return ResponseEntity.ok(ApiResponse.ok("Успешный вход", token));
        } catch (Exception e) {
            logger.warn("Login failed for user: {}. Reason: {}", request.getEmail(), e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Неверный email или пароль"));
        }
    }
}