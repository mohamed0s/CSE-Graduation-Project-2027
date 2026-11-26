using Backend.Domain.Common;
using Backend.Domain.Geography;
using NetTopologySuite.Geometries;

namespace Backend.Domain.Providers;

/// <summary>
/// Physical branch or clinic location belonging to a Provider and contained within a Zone.
/// </summary>
public class ProviderLocation : AuditableEntity
{
    public Guid ProviderId { get; set; }
    public ProviderType ProviderType { get; set; }
    public Guid ZoneId { get; set; }
    public string BranchName { get; set; } = string.Empty;
    public string AddressLine { get; set; } = string.Empty;
    public Point Location { get; set; } = null!;
    public string? PhoneNumber { get; set; }
    public bool IsActive { get; set; } = true;

    public Provider Provider { get; set; } = null!;
    public Zone Zone { get; set; } = null!;
}
