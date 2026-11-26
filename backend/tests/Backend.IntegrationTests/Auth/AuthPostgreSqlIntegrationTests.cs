using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Backend.Application.Auth;
using Backend.Infrastructure.Persistence;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Testcontainers.PostgreSql;

namespace Backend.IntegrationTests.Auth;

public class AuthPostgreSqlIntegrationTests : IAsyncLifetime
{
    private readonly PostgreSqlContainer _postgres = new PostgreSqlBuilder("postgis/postgis:16-3.4").Build();
    private WebApplicationFactory<Program> _factory = null!;
    private HttpClient _client = null!;

    public async Task InitializeAsync()
    {
        await _postgres.StartAsync();

        _factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder =>
            {
                builder.UseEnvironment("Development");
                builder.ConfigureAppConfiguration((_, config) =>
                {
                    config.AddInMemoryCollection(new Dictionary<string, string?>
                    {
                        ["ConnectionStrings:Default"] = _postgres.GetConnectionString(),
                        ["Jwt:Secret"] = "integration_test_jwt_secret_at_least_32_chars",
                        ["Jwt:Issuer"] = "finda-api",
                        ["Jwt:Audience"] = "finda-clients",
                        ["Jwt:AccessTokenMinutes"] = "15",
                        ["Jwt:RefreshTokenDays"] = "14"
                    });
                });
            });

        using var scope = _factory.Services.CreateScope();
        var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        await db.Database.MigrateAsync();

        _client = _factory.CreateClient();
    }

    public async Task DisposeAsync()
    {
        _client?.Dispose();
        if (_factory is not null)
        {
            await _factory.DisposeAsync();
        }

        await _postgres.DisposeAsync();
    }

    [Fact]
    public async Task AuthLifecycle_RegisterLoginRefreshRotateReuseLogoutAndMe_ShouldWorkEndToEnd()
    {
        // 1. Unauthorized /me
        var unauthResponse = await _client.GetAsync("/api/v1/auth/me");
        Assert.Equal(HttpStatusCode.Unauthorized, unauthResponse.StatusCode);

        // 2. Register
        var registerReq = new RegisterRequest("customer@finda.test", "StrongPass123", "Salma Customer");
        var regRes = await _client.PostAsJsonAsync("/api/v1/auth/register", registerReq);
        Assert.Equal(HttpStatusCode.Created, regRes.StatusCode);
        var regBody = await regRes.Content.ReadFromJsonAsync<AuthResponse>();
        Assert.NotNull(regBody);
        Assert.Contains("CUSTOMER", regBody!.User.Roles);

        // 3. Duplicate registration -> 409 Conflict
        var dupRes = await _client.PostAsJsonAsync("/api/v1/auth/register", registerReq);
        Assert.Equal(HttpStatusCode.Conflict, dupRes.StatusCode);

        // 4. Invalid credentials -> 401 Unauthorized
        var badLogin = await _client.PostAsJsonAsync("/api/v1/auth/login", new LoginRequest("customer@finda.test", "Wrong123"));
        Assert.Equal(HttpStatusCode.Unauthorized, badLogin.StatusCode);

        // 5. Login -> 200 OK
        var loginRes = await _client.PostAsJsonAsync("/api/v1/auth/login", new LoginRequest("customer@finda.test", "StrongPass123"));
        Assert.Equal(HttpStatusCode.OK, loginRes.StatusCode);
        var loginBody = await loginRes.Content.ReadFromJsonAsync<AuthResponse>();
        Assert.NotNull(loginBody);

        // 6. GET /me with Bearer token
        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", loginBody!.AccessToken);
        var meRes = await _client.GetAsync("/api/v1/auth/me");
        Assert.Equal(HttpStatusCode.OK, meRes.StatusCode);

        // 7. Refresh token rotation
        var refreshRes = await _client.PostAsJsonAsync("/api/v1/auth/refresh", new RefreshTokenRequest(loginBody.RefreshToken));
        Assert.Equal(HttpStatusCode.OK, refreshRes.StatusCode);
        var rotated = await refreshRes.Content.ReadFromJsonAsync<AuthResponse>();
        Assert.NotNull(rotated);
        Assert.NotEqual(loginBody.RefreshToken, rotated!.RefreshToken);

        // 8. Reuse of old refresh token -> 401 and revokes new token too
        var reuseRes = await _client.PostAsJsonAsync("/api/v1/auth/refresh", new RefreshTokenRequest(loginBody.RefreshToken));
        Assert.Equal(HttpStatusCode.Unauthorized, reuseRes.StatusCode);

        var revokedNewRes = await _client.PostAsJsonAsync("/api/v1/auth/refresh", new RefreshTokenRequest(rotated.RefreshToken));
        Assert.Equal(HttpStatusCode.Unauthorized, revokedNewRes.StatusCode);
    }
}
