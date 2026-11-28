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
    private readonly PostgreSqlContainer _postgres = new PostgreSqlBuilder("postgis/postgis:16-3.4")
        .WithDatabase("finda_test")
        .WithUsername("finda_test")
        .WithPassword("finda_test_pw")
        .Build();
    private WebApplicationFactory<Program> _factory = null!;
    private HttpClient _client = null!;

    public async Task InitializeAsync()
    {
        await _postgres.StartAsync();

        _factory = new WebApplicationFactory<Program>()
            .WithWebHostBuilder(builder =>
            {
                builder.UseEnvironment("Testing");
                builder.UseSetting("ConnectionStrings:Default", _postgres.GetConnectionString());
                builder.UseSetting("Jwt:Secret", "integration_test_jwt_secret_at_least_32_chars");
                builder.UseSetting("Jwt:Issuer", "finda-api");
                builder.UseSetting("Jwt:Audience", "finda-clients");
                builder.UseSetting("Jwt:AccessTokenMinutes", "15");
                builder.UseSetting("Jwt:RefreshTokenDays", "14");
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

        // 9. Fresh login -> Logout -> Refresh fails
        var login2Res = await _client.PostAsJsonAsync("/api/v1/auth/login", new LoginRequest("customer@finda.test", "StrongPass123"));
        Assert.Equal(HttpStatusCode.OK, login2Res.StatusCode);
        var login2Body = await login2Res.Content.ReadFromJsonAsync<AuthResponse>();
        Assert.NotNull(login2Body);

        _client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", login2Body!.AccessToken);
        var logoutRes = await _client.PostAsJsonAsync("/api/v1/auth/logout", new LogoutRequest(login2Body.RefreshToken));
        Assert.Equal(HttpStatusCode.NoContent, logoutRes.StatusCode);

        var afterLogoutRefresh = await _client.PostAsJsonAsync("/api/v1/auth/refresh", new RefreshTokenRequest(login2Body.RefreshToken));
        Assert.Equal(HttpStatusCode.Unauthorized, afterLogoutRefresh.StatusCode);
    }

    [Fact]
    public async Task Register_WithPlainEmailAndValidPayload_ShouldReturn201Created()
    {
        var request = new RegisterRequest("ah@gmail.com", "123d@G4x", "Ahmed hAA", "01010122847");

        var response = await _client.PostAsJsonAsync("/api/v1/auth/register", request);
        Assert.Equal(HttpStatusCode.Created, response.StatusCode);

        var body = await response.Content.ReadFromJsonAsync<AuthResponse>();
        Assert.NotNull(body);
        Assert.Equal("ah@gmail.com", body!.User.Email);
        Assert.Contains("CUSTOMER", body.User.Roles);
    }

    [Theory]
    [InlineData("[ah@gmail.com](mailto:ah@gmail.com)", "123d@G4x", "Ahmed hAA", "01010122847", "email")]
    [InlineData("valid@gmail.com", "123d@g4x", "Ahmed hAA", "01010122847", "password")]
    [InlineData("valid@gmail.com", "123D@G4X", "Ahmed hAA", "01010122847", "password")]
    [InlineData("valid@gmail.com", "abcD@efg", "Ahmed hAA", "01010122847", "password")]
    [InlineData("valid@gmail.com", "123d@Gx", "Ahmed hAA", "01010122847", "password")]
    [InlineData("valid@gmail.com", "123d@G4x", "A", "01010122847", "fullName")]
    [InlineData("valid@gmail.com", "123d@G4x", "Ahmed hAA", "01234567890123456789012345678901", "phoneNumber")]
    public async Task Register_WithInvalidField_ShouldReturn400WithFieldLevelErrors(
        string email,
        string password,
        string fullName,
        string phoneNumber,
        string expectedErrorField)
    {
        var request = new RegisterRequest(email, password, fullName, phoneNumber);

        var response = await _client.PostAsJsonAsync("/api/v1/auth/register", request);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);

        var rawBody = await response.Content.ReadAsStringAsync();
        Assert.Contains("\"errors\"", rawBody);
        Assert.Contains($"\"{expectedErrorField}\"", rawBody);
        Assert.DoesNotContain(password, rawBody);
    }

    [Fact]
    public async Task UnversionedAuthRoutes_ShouldReturn404()
    {
        var unversionedRegister = await _client.PostAsJsonAsync("/api/auth/register", new RegisterRequest("a@b.com", "Test1234@", "Test User"));
        var unversionedLogin = await _client.PostAsJsonAsync("/api/auth/login", new LoginRequest("a@b.com", "Test1234@"));
        var unversionedRefresh = await _client.PostAsJsonAsync("/api/auth/refresh", new RefreshTokenRequest("tok"));
        var unversionedLogout = await _client.PostAsJsonAsync("/api/auth/logout", new LogoutRequest("tok"));
        var unversionedMe = await _client.GetAsync("/api/auth/me");

        Assert.Equal(HttpStatusCode.NotFound, unversionedRegister.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, unversionedLogin.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, unversionedRefresh.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, unversionedLogout.StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, unversionedMe.StatusCode);
    }
}
