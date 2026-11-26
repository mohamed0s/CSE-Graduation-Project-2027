using Backend.Domain.Common;
using Backend.Domain.Identity;

namespace Backend.Domain.Providers;

/// <summary>
/// Shared provider supertype (Option B). Each provider belongs to exactly one category (ProviderType).
/// </summary>
public class Provider : AuditableEntity
{
    public Guid OwnerUserId { get; set; }
    public ProviderType ProviderType { get; set; }
    public bool IsActive { get; set; } = true;

    public User OwnerUser { get; set; } = null!;
    public ICollection<ProviderLocation> Locations { get; set; } = new List<ProviderLocation>();
}
