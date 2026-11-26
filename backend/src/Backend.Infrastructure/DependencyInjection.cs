using System.Text;
using Backend.Application.Auth;
using Backend.Application.Common.Interfaces;
using Backend.Infrastructure.Identity;
using Backend.Infrastructure.Options;
using Backend.Infrastructure.Persistence;
using Backend.Infrastructure.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;

namespace Backend.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration,
        bool isDevelopment)
    {
        services.AddSingleton<IDateTimeProvider, SystemDateTimeProvider>();
        services.AddSingleton<IPasswordHashingService, PasswordHashingService>();
        services.AddScoped<ITokenService, JwtTokenService>();

        var connectionString = configuration.GetConnectionString("Default");
        if (string.IsNullOrWhiteSpace(connectionString))
        {
            if (!isDevelopment)
            {
                throw new InvalidOperationException("Required configuration 'ConnectionStrings:Default' is missing.");
            }

            // Placeholder for Development startup when DB is not yet configured; /health will report degraded/unhealthy if DB is probed.
            connectionString = "Host=localhost;Port=5432;Database=finda;Username=postgres;Password=postgres";
        }

        services.AddDbContext<AppDbContext>(options =>
            options.UseNpgsql(
                connectionString,
                npgsql => npgsql.UseNetTopologySuite()));

        services.AddScoped<IAppDbContext>(sp => sp.GetRequiredService<AppDbContext>());

        var jwtOptionsBuilder = services.AddOptions<JwtOptions>()
            .Bind(configuration.GetSection(JwtOptions.SectionName));

        if (!isDevelopment)
        {
            jwtOptionsBuilder.ValidateDataAnnotations().ValidateOnStart();
        }

        var jwtOptions = configuration.GetSection(JwtOptions.SectionName).Get<JwtOptions>() ?? new JwtOptions();
        if (string.IsNullOrWhiteSpace(jwtOptions.Secret) || jwtOptions.Secret.Length < 32)
        {
            if (!isDevelopment)
            {
                throw new InvalidOperationException("Required configuration 'Jwt:Secret' must be at least 32 characters in non-Development environments.");
            }
        }
        else
        {
            services.AddAuthentication(options =>
                {
                    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                })
                .AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {
                        ValidateIssuer = true,
                        ValidIssuer = jwtOptions.Issuer,
                        ValidateAudience = true,
                        ValidAudience = jwtOptions.Audience,
                        ValidateLifetime = true,
                        ClockSkew = TimeSpan.FromSeconds(30),
                        ValidateIssuerSigningKey = true,
                        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtOptions.Secret))
                    };
                });
        }

        services.AddAuthorization();

        var healthChecks = services.AddHealthChecks();
        if (!string.IsNullOrWhiteSpace(configuration.GetConnectionString("Default")))
        {
            healthChecks.AddDbContextCheck<AppDbContext>("postgres");
        }

        return services;
    }
}
