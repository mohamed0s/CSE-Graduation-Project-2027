using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Backend.Application.Auth;
using Backend.Application.Common.Interfaces;
using Backend.Domain.Identity;
using Backend.Infrastructure.Options;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Backend.Infrastructure.Identity;

public sealed class JwtTokenService : ITokenService
{
    private readonly JwtOptions _options;
    private readonly IDateTimeProvider _clock;

    public JwtTokenService(IOptions<JwtOptions> options, IDateTimeProvider clock)
    {
        _options = options.Value;
        _clock = clock;
    }

    public (string AccessToken, DateTimeOffset ExpiresAt) GenerateAccessToken(
        User user,
        IReadOnlyCollection<string> roles)
    {
        if (string.IsNullOrWhiteSpace(_options.Secret) || _options.Secret.Length < 32)
        {
            throw new InvalidOperationException("Jwt:Secret must be configured with at least 32 characters.");
        }

        var now = _clock.UtcNow;
        var expiresAt = now.AddMinutes(_options.AccessTokenMinutes);

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
            new(JwtRegisteredClaimNames.Email, user.Email),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
            new(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new(ClaimTypes.Email, user.Email)
        };

        foreach (var role in roles)
        {
            claims.Add(new Claim(ClaimTypes.Role, role));
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_options.Secret));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var token = new JwtSecurityToken(
            issuer: _options.Issuer,
            audience: _options.Audience,
            claims: claims,
            notBefore: now.UtcDateTime,
            expires: expiresAt.UtcDateTime,
            signingCredentials: credentials);

        return (new JwtSecurityTokenHandler().WriteToken(token), expiresAt);
    }

    public string GenerateRefreshToken()
    {
        var bytes = RandomNumberGenerator.GetBytes(64);
        return Convert.ToBase64String(bytes)
            .Replace('+', '-')
            .Replace('/', '_')
            .TrimEnd('=');
    }

    public string HashRefreshToken(string refreshToken)
    {
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(refreshToken));
        return Convert.ToHexString(hash).ToLowerInvariant();
    }

    public DateTimeOffset GetRefreshTokenExpiry() =>
        _clock.UtcNow.AddDays(_options.RefreshTokenDays);
}
