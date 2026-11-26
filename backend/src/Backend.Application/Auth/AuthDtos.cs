namespace Backend.Application.Auth;

public sealed record RegisterRequest(
    string Email,
    string Password,
    string FullName,
    string? PhoneNumber = null);

public sealed record LoginRequest(
    string Email,
    string Password);

public sealed record RefreshTokenRequest(
    string RefreshToken);

public sealed record LogoutRequest(
    string RefreshToken);

public sealed record AuthUserDto(
    Guid Id,
    string Email,
    string FullName,
    IReadOnlyCollection<string> Roles);

public sealed record AuthResponse(
    string AccessToken,
    DateTimeOffset ExpiresAt,
    string RefreshToken,
    AuthUserDto User);

public sealed record CurrentUserProfileDto(
    Guid Id,
    string Email,
    string FullName,
    string? PhoneNumber,
    string Status,
    IReadOnlyCollection<string> Roles,
    Guid? SelectedZoneId,
    string? DefaultAddress);
