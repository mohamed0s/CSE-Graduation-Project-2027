using Backend.Domain.Common;
using Backend.Domain.Geography;

namespace Backend.Domain.Identity;

/// <summary>
/// Customer-specific profile holding the global selected geographic zone.
/// </summary>
public class CustomerProfile : AuditableEntity
{
    public Guid UserId { get; set; }
    public Guid? SelectedZoneId { get; set; }
    public string? DefaultAddress { get; set; }

    public User User { get; set; } = null!;
    public Zone? SelectedZone { get; set; }
}
