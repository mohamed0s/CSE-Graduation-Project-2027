using Backend.Domain.Common;

namespace Backend.Domain.Identity;

/// <summary>
/// Coarse-grained platform role (CUSTOMER, GENERAL_PROVIDER, RESTAURANT_PROVIDER, HEALTHCARE_PROVIDER, ADMIN).
/// </summary>
public class Role : AuditableEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }

    public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
}
