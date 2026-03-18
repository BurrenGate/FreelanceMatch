package sdu.database.piedpiper.security;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import sdu.database.piedpiper.model.Account;

import java.util.Collection;
import java.util.List;

public class CustomUserDetails implements UserDetails {

    private final Account account;

    public CustomUserDetails(Account account) {
        this.account = account;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        // Маппим наши ID ролей из базы в строковые названия для Spring Security
        String roleName = switch (account.getRoleId()) {
            case 1 -> "ROLE_CLIENT";
            case 2 -> "ROLE_FREELANCER";
            case 3 -> "ROLE_ADMIN";
            default -> "ROLE_USER";
        };
        return List.of(new SimpleGrantedAuthority(roleName));
    }

    @Override
    public String getPassword() {
        return account.getPasswordHash();
    }

    @Override
    public String getUsername() {
        return account.getEmail(); // В качестве логина используем email
    }

    public Account getAccount() {
        return account;
    }

    @Override
    public boolean isAccountNonExpired() { return true; }
    @Override
    public boolean isAccountNonLocked() { return "active".equals(account.getStatus()); }
    @Override
    public boolean isCredentialsNonExpired() { return true; }
    @Override
    public boolean isEnabled() { return "active".equals(account.getStatus()); }
}