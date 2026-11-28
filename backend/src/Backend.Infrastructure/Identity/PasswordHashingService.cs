using Backend.Application.Auth;
using Backend.Domain.Identity;
using Microsoft.AspNetCore.Identity;

namespace Backend.Infrastructure.Identity;

public sealed class PasswordHashingService : IPasswordHashingService
{
    private readonly PasswordHasher<User> _hasher = new();

    public string HashPassword(User user, string password) =>
        _hasher.HashPassword(user, password);

    public bool VerifyPassword(User user, string password) =>
        _hasher.VerifyHashedPassword(user, user.PasswordHash, password) != PasswordVerificationResult.Failed;
}
