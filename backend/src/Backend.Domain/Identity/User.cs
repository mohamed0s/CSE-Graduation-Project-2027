using Backend.Domain.Common;
using Backend.Domain.Providers;

namespace Backend.Domain.Identity;

/// <summary>
/// Core user account shared across all FINDA domains.
/// </summary>
public class User : AuditableEntity
{
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public string FullName { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public UserStatus Status { get; set; } = UserStatus.ACTIVE;
    public DateTimeOffset? DeletedAt { get; set; }

    public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
    public ICollection<RefreshToken> RefreshTokens { get; set; } = new List<RefreshToken>();
    public CustomerProfile? CustomerProfile { get; set; }
    public ICollection<Provider> OwnedProviders { get; set; } = new List<Provider>();
}
