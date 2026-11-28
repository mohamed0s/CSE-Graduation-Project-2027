namespace Backend.Domain.Common;

/// <summary>
/// Base class for entities with a UUID primary key and UTC audit timestamps.
/// </summary>
public abstract class AuditableEntity
{
    public Guid Id { get; set; }
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }
}
