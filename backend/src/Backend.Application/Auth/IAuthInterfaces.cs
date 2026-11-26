using Backend.Domain.Identity;

namespace Backend.Application.Auth;

public interface IPasswordHashingService
{
    string HashPassword(User user, string password);
    bool VerifyPassword(User user, string password);
}

public interface ITokenService
{
    (string AccessToken, DateTimeOffset ExpiresAt) GenerateAccessToken(User user, IReadOnlyCollection<string> roles);
    string GenerateRefreshToken();
    string HashRefreshToken(string refreshToken);
    DateTimeOffset GetRefreshTokenExpiry();
}

public interface IAuthService
{
    Task<AuthResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default);
    Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default);
    Task<AuthResponse> RefreshAsync(RefreshTokenRequest request, CancellationToken cancellationToken = default);
    Task LogoutAsync(Guid userId, LogoutRequest request, CancellationToken cancellationToken = default);
    Task<CurrentUserProfileDto> GetCurrentUserAsync(Guid userId, CancellationToken cancellationToken = default);
}
