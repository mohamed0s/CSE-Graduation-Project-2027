using Backend.Domain.Providers;

namespace Backend.Domain.Healthcare;

public class ProviderSchedule
{
    public Guid Id { get; set; }
    public Guid ProviderLocationId { get; set; }
    public ProviderType ProviderType { get; set; } = ProviderType.HEALTHCARE;
    public short DayOfWeek { get; set; }
    public TimeOnly StartTime { get; set; }
    public TimeOnly EndTime { get; set; }
    public bool IsActive { get; set; } = true;

    public ProviderLocation ProviderLocation { get; set; } = null!;
}
