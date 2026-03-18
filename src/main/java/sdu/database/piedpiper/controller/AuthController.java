package sdu.database.piedpiper.controller;

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

    public AuthController(AuthenticationManager authenticationManager, JwtUtil jwtUtil, AccountService accountService) {
        this.authenticationManager = authenticationManager;
        this.jwtUtil = jwtUtil;
        this.accountService = accountService;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<Void>> register(@RequestBody RegisterRequest request) {
        try {
            accountService.registerAccount(request);
            return ResponseEntity.ok(ApiResponse.ok("Пользователь успешно зарегистрирован!", null));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(ApiResponse.error(e.getMessage()));
        }
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<String>> login(@RequestBody LoginRequest request) {
        try {
            // Spring Security сам проверит пароль под капотом
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
            );

            // Если дошли сюда, пароль верный. Достаем юзера из БД, чтобы узнать его роль
            Account account = accountService.findByEmail(request.getEmail());

            // Генерируем токен
            String token = jwtUtil.generateToken(account.getEmail(), account.getRoleId());

            return ResponseEntity.ok(ApiResponse.ok("Успешный вход", token));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(ApiResponse.error("Неверный email или пароль"));
        }
    }
}