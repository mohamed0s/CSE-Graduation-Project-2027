using Backend.Domain.Common;
using Backend.Domain.Identity;
using Backend.Domain.Providers;
using NetTopologySuite.Geometries;

namespace Backend.Domain.Geography;

/// <summary>
/// Global geographic zone (or optional child neighborhood) with a PostGIS MultiPolygon boundary (SRID 4326).
/// </summary>
public class Zone : AuditableEntity
{
    public Guid? ParentZoneId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public ZoneType ZoneType { get; set; } = ZoneType.ZONE;
    public MultiPolygon Boundary { get; set; } = null!;
    public Point? Centroid { get; set; }
    public bool IsActive { get; set; } = true;

    public Zone? ParentZone { get; set; }
    public ICollection<Zone> ChildZones { get; set; } = new List<Zone>();
    public ICollection<CustomerProfile> SelectingCustomers { get; set; } = new List<CustomerProfile>();
    public ICollection<ProviderLocation> ProviderLocations { get; set; } = new List<ProviderLocation>();
}
