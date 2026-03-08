package sdu.database.piedpiper.model;

/**
 * Generic API response wrapper so the frontend always gets a
 * predictable JSON shape: { "success": true, "message": "...", "data": ... }
 */
public class ApiResponse<T> {
    private boolean success;
    private String  message;
    private T       data;

    // ── Constructors ─────────────────────────────────────────

    public ApiResponse() {}

    public ApiResponse(boolean success, String message, T data) {
        this.success = success;
        this.message = message;
        this.data    = data;
    }

    /** Convenience factory for success responses */
    public static <T> ApiResponse<T> ok(String message, T data) {
        return new ApiResponse<>(true, message, data);
    }

    /** Convenience factory for error responses */
    public static <T> ApiResponse<T> error(String message) {
        return new ApiResponse<>(false, message, null);
    }

    // ── Getters & Setters ────────────────────────────────────

    public boolean isSuccess()        { return success; }
    public void setSuccess(boolean v) { this.success = v; }

    public String getMessage()        { return message; }
    public void setMessage(String v)  { this.message = v; }

    public T getData()                { return data; }
    public void setData(T v)          { this.data = v; }
}