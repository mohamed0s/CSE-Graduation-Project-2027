using Backend.Domain.Providers;

namespace Backend.Domain.Healthcare;

public class ScheduleException
{
    public Guid Id { get; set; }
    public Guid ProviderLocationId { get; set; }
    public ProviderType ProviderType { get; set; } = ProviderType.HEALTHCARE;
    public DateOnly ExceptionDate { get; set; }
    public bool IsDayOff { get; set; } = true;
    public TimeOnly? StartTime { get; set; }
    public TimeOnly? EndTime { get; set; }
    public string? Reason { get; set; }
    public DateTimeOffset CreatedAt { get; set; }

    public ProviderLocation ProviderLocation { get; set; } = null!;
}
