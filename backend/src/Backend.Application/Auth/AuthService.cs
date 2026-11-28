using Backend.Application.Common.Interfaces;
using Backend.Domain.Exceptions;
using Backend.Domain.Identity;
using FluentValidation;
using Microsoft.EntityFrameworkCore;

namespace Backend.Application.Auth;

public sealed class AuthService : IAuthService
{
    private readonly IAppDbContext _db;
    private readonly IPasswordHashingService _passwordHasher;
    private readonly ITokenService _tokenService;
    private readonly IDateTimeProvider _clock;
    private readonly IValidator<RegisterRequest> _registerValidator;
    private readonly IValidator<LoginRequest> _loginValidator;
    private readonly IValidator<RefreshTokenRequest> _refreshValidator;
    private readonly IValidator<LogoutRequest> _logoutValidator;

    public AuthService(
        IAppDbContext db,
        IPasswordHashingService passwordHasher,
        ITokenService tokenService,
        IDateTimeProvider clock,
        IValidator<RegisterRequest> registerValidator,
        IValidator<LoginRequest> loginValidator,
        IValidator<RefreshTokenRequest> refreshValidator,
        IValidator<LogoutRequest> logoutValidator)
    {
        _db = db;
        _passwordHasher = passwordHasher;
        _tokenService = tokenService;
        _clock = clock;
        _registerValidator = registerValidator;
        _loginValidator = loginValidator;
        _refreshValidator = refreshValidator;
        _logoutValidator = logoutValidator;
    }

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default)
    {
        await _registerValidator.ValidateAndThrowAsync(request, cancellationToken);

        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        var exists = await _db.Users.AnyAsync(u => u.Email == normalizedEmail, cancellationToken);
        if (exists)
        {
            throw new ConflictException("An account with this email already exists.");
        }

        var customerRole = await _db.Roles
            .FirstOrDefaultAsync(r => r.Name == RoleNames.Customer, cancellationToken);

        if (customerRole is null)
        {
            customerRole = new Role
            {
                Id = Guid.NewGuid(),
                Name = RoleNames.Customer,
                Description = "Standard FINDA customer role"
            };
            _db.Roles.Add(customerRole);
        }

        var now = _clock.UtcNow;
        var user = new User
        {
            Id = Guid.NewGuid(),
            Email = normalizedEmail,
            FullName = request.FullName.Trim(),
            PhoneNumber = string.IsNullOrWhiteSpace(request.PhoneNumber) ? null : request.PhoneNumber.Trim(),
            Status = UserStatus.ACTIVE,
            CreatedAt = now,
            UpdatedAt = now
        };
        user.PasswordHash = _passwordHasher.HashPassword(user, request.Password);

        var userRole = new UserRole
        {
            UserId = user.Id,
            RoleId = customerRole.Id,
            AssignedAt = now
        };

        var customerProfile = new CustomerProfile
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            CreatedAt = now,
            UpdatedAt = now
        };

        var rawRefreshToken = _tokenService.GenerateRefreshToken();
        var refreshTokenEntity = new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            TokenHash = _tokenService.HashRefreshToken(rawRefreshToken),
            ExpiresAt = _tokenService.GetRefreshTokenExpiry(),
            CreatedAt = now
        };

        _db.Users.Add(user);
        _db.UserRoles.Add(userRole);
        _db.CustomerProfiles.Add(customerProfile);
        _db.RefreshTokens.Add(refreshTokenEntity);

        await _db.SaveChangesAsync(cancellationToken);

        var roles = new[] { RoleNames.Customer };
        var (accessToken, expiresAt) = _tokenService.GenerateAccessToken(user, roles);

        return new AuthResponse(
            accessToken,
            expiresAt,
            rawRefreshToken,
            new AuthUserDto(user.Id, user.Email, user.FullName, roles));
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default)
    {
        await _loginValidator.ValidateAndThrowAsync(request, cancellationToken);

        var normalizedEmail = request.Email.Trim().ToLowerInvariant();
        var user = await _db.Users
            .Include(u => u.UserRoles)
            .ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(u => u.Email == normalizedEmail, cancellationToken);

        if (user is null || !_passwordHasher.VerifyPassword(user, request.Password))
        {
            throw new UnauthorizedAccessException("Invalid email or password.");
        }

        if (user.Status != UserStatus.ACTIVE)
        {
            throw new ForbiddenException("This account is not active.");
        }

        var roles = user.UserRoles.Select(ur => ur.Role.Name).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
        var (accessToken, expiresAt) = _tokenService.GenerateAccessToken(user, roles);

        var rawRefreshToken = _tokenService.GenerateRefreshToken();
        var refreshTokenEntity = new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            TokenHash = _tokenService.HashRefreshToken(rawRefreshToken),
            ExpiresAt = _tokenService.GetRefreshTokenExpiry(),
            CreatedAt = _clock.UtcNow
        };

        _db.RefreshTokens.Add(refreshTokenEntity);
        await _db.SaveChangesAsync(cancellationToken);

        return new AuthResponse(
            accessToken,
            expiresAt,
            rawRefreshToken,
            new AuthUserDto(user.Id, user.Email, user.FullName, roles));
    }

    public async Task<AuthResponse> RefreshAsync(RefreshTokenRequest request, CancellationToken cancellationToken = default)
    {
        await _refreshValidator.ValidateAndThrowAsync(request, cancellationToken);

        var now = _clock.UtcNow;
        var incomingHash = _tokenService.HashRefreshToken(request.RefreshToken);

        var existingToken = await _db.RefreshTokens
            .Include(rt => rt.User)
            .ThenInclude(u => u.UserRoles)
            .ThenInclude(ur => ur.Role)
            .FirstOrDefaultAsync(rt => rt.TokenHash == incomingHash, cancellationToken);

        if (existingToken is null)
        {
            throw new UnauthorizedAccessException("Invalid refresh token.");
        }

        // Reuse detection: if an already-revoked token is presented, revoke all active tokens for this user
        if (existingToken.RevokedAt is not null)
        {
            var activeTokens = await _db.RefreshTokens
                .Where(rt => rt.UserId == existingToken.UserId && rt.RevokedAt == null)
                .ToListAsync(cancellationToken);

            foreach (var token in activeTokens)
            {
                token.RevokedAt = now;
            }

            await _db.SaveChangesAsync(cancellationToken);
            throw new UnauthorizedAccessException("Refresh token reuse detected. All sessions have been revoked.");
        }

        if (existingToken.ExpiresAt <= now)
        {
            throw new UnauthorizedAccessException("Refresh token has expired.");
        }

        var user = existingToken.User;
        if (user.Status != UserStatus.ACTIVE)
        {
            throw new ForbiddenException("This account is not active.");
        }

        var newRawRefreshToken = _tokenService.GenerateRefreshToken();
        var newRefreshTokenEntity = new RefreshToken
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            TokenHash = _tokenService.HashRefreshToken(newRawRefreshToken),
            ExpiresAt = _tokenService.GetRefreshTokenExpiry(),
            CreatedAt = now
        };

        existingToken.RevokedAt = now;
        existingToken.ReplacedByTokenId = newRefreshTokenEntity.Id;

        _db.RefreshTokens.Add(newRefreshTokenEntity);
        await _db.SaveChangesAsync(cancellationToken);

        var roles = user.UserRoles.Select(ur => ur.Role.Name).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
        var (accessToken, expiresAt) = _tokenService.GenerateAccessToken(user, roles);

        return new AuthResponse(
            accessToken,
            expiresAt,
            newRawRefreshToken,
            new AuthUserDto(user.Id, user.Email, user.FullName, roles));
    }

    public async Task LogoutAsync(Guid userId, LogoutRequest request, CancellationToken cancellationToken = default)
    {
        await _logoutValidator.ValidateAndThrowAsync(request, cancellationToken);

        var tokenHash = _tokenService.HashRefreshToken(request.RefreshToken);
        var token = await _db.RefreshTokens
            .FirstOrDefaultAsync(rt => rt.TokenHash == tokenHash && rt.UserId == userId, cancellationToken);

        if (token is not null && token.RevokedAt is null)
        {
            token.RevokedAt = _clock.UtcNow;
            await _db.SaveChangesAsync(cancellationToken);
        }
    }

    public async Task<CurrentUserProfileDto> GetCurrentUserAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await _db.Users
            .AsNoTracking()
            .Include(u => u.UserRoles)
            .ThenInclude(ur => ur.Role)
            .Include(u => u.CustomerProfile)
            .FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);

        if (user is null)
        {
            throw new NotFoundException("User not found.");
        }

        var roles = user.UserRoles.Select(ur => ur.Role.Name).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();

        return new CurrentUserProfileDto(
            user.Id,
            user.Email,
            user.FullName,
            user.PhoneNumber,
            user.Status.ToString(),
            roles,
            user.CustomerProfile?.SelectedZoneId,
            user.CustomerProfile?.DefaultAddress);
    }
}
