using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Backend.Api.Middleware;
using Backend.Application.Auth;
using Backend.Domain.Exceptions;
using Backend.Domain.Identity;
using Backend.Infrastructure;
using Backend.Infrastructure.Identity;
using Backend.Infrastructure.Options;
using Backend.Infrastructure.Services;
using FluentValidation;
using FluentValidation.Results;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.FileProviders;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace Backend.UnitTests.Auth;

public class JwtAndSecurityTests
{
    private static JwtOptions CreateValidJwtOptions() => new()
    {
        Secret = "super_secret_test_key_at_least_32_characters_long",
        Issuer = "finda-api",
        Audience = "finda-clients",
        AccessTokenMinutes = 15,
        RefreshTokenDays = 14
    };

    [Fact]
    public void PasswordHashing_ShouldHashAndVerifyWithoutStoringPlaintext()
    {
        var hasher = new PasswordHashingService();
        var user = new User { Id = Guid.NewGuid(), Email = "test@finda.app" };

        var hash = hasher.HashPassword(user, "StrongPass123");
        user.PasswordHash = hash;

        Assert.NotEqual("StrongPass123", hash);
        Assert.True(hasher.VerifyPassword(user, "StrongPass123"));
        Assert.False(hasher.VerifyPassword(user, "WrongPass123"));
    }

    [Fact]
    public void JwtTokenService_ShouldGenerateValidTokenWithRoleClaims_AndHashRefreshTokens()
    {
        var jwtOptions = CreateValidJwtOptions();
        var service = new JwtTokenService(Options.Create(jwtOptions), new SystemDateTimeProvider());
        var user = new User { Id = Guid.NewGuid(), Email = "ahmed@finda.app" };
        var roles = new[] { RoleNames.Customer, RoleNames.GeneralProvider };

        var (accessToken, expiresAt) = service.GenerateAccessToken(user, roles);
        Assert.True(expiresAt > DateTimeOffset.UtcNow);

        var handler = new JwtSecurityTokenHandler();
        var principal = handler.ValidateToken(accessToken, new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtOptions.Issuer,
            ValidateAudience = true,
            ValidAudience = jwtOptions.Audience,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtOptions.Secret))
        }, out _);

        Assert.Equal(user.Id.ToString(), principal.FindFirstValue(ClaimTypes.NameIdentifier));
        Assert.Equal(user.Email, principal.FindFirstValue(ClaimTypes.Email));
        var tokenRoles = principal.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();
        Assert.Contains(RoleNames.Customer, tokenRoles);
        Assert.Contains(RoleNames.GeneralProvider, tokenRoles);

        var rawRefresh = service.GenerateRefreshToken();
        var hash = service.HashRefreshToken(rawRefresh);
        Assert.NotEqual(rawRefresh, hash);
        Assert.Equal(64, hash.Length); // SHA-256 hex
        Assert.Equal(hash, service.HashRefreshToken(rawRefresh));
    }

    [Fact]
    public void RegisterValidator_ShouldRejectWeakPassword_AndAcceptStrongPassword()
    {
        var validator = new RegisterRequestValidator();

        var invalid = validator.Validate(new RegisterRequest("bad-email", "weak", "A"));
        Assert.False(invalid.IsValid);

        var valid = validator.Validate(new RegisterRequest("user@finda.app", "StrongPass123", "Ahmed Ali"));
        Assert.True(valid.IsValid);
    }

    [Theory]
    [InlineData(typeof(NotFoundException), 404)]
    [InlineData(typeof(ConflictException), 409)]
    [InlineData(typeof(ForbiddenException), 403)]
    [InlineData(typeof(UnauthorizedAccessException), 401)]
    [InlineData(typeof(DomainValidationException), 400)]
    public async Task GlobalExceptionHandler_ShouldMapDomainExceptionsToProblemDetails(Type exceptionType, int expectedStatus)
    {
        var handler = new GlobalExceptionHandler(
            NullLogger<GlobalExceptionHandler>.Instance,
            new StubHostEnvironment { EnvironmentName = Environments.Production });

        var context = new DefaultHttpContext();
        context.Response.Body = new MemoryStream();
        var ex = (Exception)Activator.CreateInstance(exceptionType, "test error")!;

        var handled = await handler.TryHandleAsync(context, ex, CancellationToken.None);

        Assert.True(handled);
        Assert.Equal(expectedStatus, context.Response.StatusCode);
    }

    [Fact]
    public async Task GlobalExceptionHandler_ShouldReturnValidationProblemDetails()
    {
        var handler = new GlobalExceptionHandler(
            NullLogger<GlobalExceptionHandler>.Instance,
            new StubHostEnvironment { EnvironmentName = Environments.Production });

        var context = new DefaultHttpContext();
        context.Response.Body = new MemoryStream();
        var ex = new ValidationException([new FluentValidation.Results.ValidationFailure("Email", "Invalid email")]);

        var handled = await handler.TryHandleAsync(context, ex, CancellationToken.None);

        Assert.True(handled);
        Assert.Equal(400, context.Response.StatusCode);

        context.Response.Body.Position = 0;
        using var reader = new StreamReader(context.Response.Body);
        var json = await reader.ReadToEndAsync();
        Assert.Contains("\"errors\"", json);
        Assert.Contains("\"email\"", json);
        Assert.Contains("Invalid email", json);
    }

    [Theory]
    [InlineData(false)]
    [InlineData(true)]
    public void AddInfrastructure_ShouldFailFastWhenConnectionStringMissing(bool isDevelopment)
    {
        var services = new ServiceCollection();
        var emptyConfig = new ConfigurationBuilder().Build();

        Assert.Throws<InvalidOperationException>(() =>
            services.AddInfrastructure(emptyConfig, isDevelopment: isDevelopment));
    }

    private sealed class StubHostEnvironment : IHostEnvironment
    {
        public string EnvironmentName { get; set; } = Environments.Development;
        public string ApplicationName { get; set; } = "Backend.Api";
        public string ContentRootPath { get; set; } = AppContext.BaseDirectory;
        public IFileProvider ContentRootFileProvider { get; set; } = new NullFileProvider();
    }
}
