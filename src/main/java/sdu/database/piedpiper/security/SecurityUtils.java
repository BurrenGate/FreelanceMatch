package sdu.database.piedpiper.security;

import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;

public class SecurityUtils {

    public static String getCurrentUsername() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof UserDetails) {
            return ((UserDetails) principal).getUsername();
        } else {
            return principal.toString();
        }
    }

    public static Integer getCurrentUserRoleId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof CustomUserDetails) {
            return ((CustomUserDetails) principal).getAccount().getRoleId();
        }
        return null;
    }

    public static Long getCurrentUserId() {
        Object principal = SecurityContextHolder.getContext().getAuthentication().getPrincipal();
        if (principal instanceof CustomUserDetails) {
            return ((CustomUserDetails) principal).getAccount().getId();
        }
        return null;
    }

    public static boolean isFreelancer() {
        Integer roleId = getCurrentUserRoleId();
        return roleId != null && roleId == 2;
    }

    public static boolean isClient() {
        Integer roleId = getCurrentUserRoleId();
        return roleId != null && roleId == 1;
    }

    public static boolean isAdmin() {
        Integer roleId = getCurrentUserRoleId();
        return roleId != null && roleId == 3;
    }

    public static boolean hasRole(Integer roleId) {
        Integer currentRoleId = getCurrentUserRoleId();
        return currentRoleId != null && currentRoleId.equals(roleId);
    }

    public static boolean hasAnyRole(Integer... roleIds) {
        Integer currentRoleId = getCurrentUserRoleId();
        if (currentRoleId == null) return false;
        for (Integer roleId : roleIds) {
            if (currentRoleId.equals(roleId)) return true;
        }
        return false;
    }
}
