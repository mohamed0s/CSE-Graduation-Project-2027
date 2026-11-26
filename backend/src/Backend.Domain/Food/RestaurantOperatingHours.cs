using Backend.Domain.Providers;

namespace Backend.Domain.Food;

public class RestaurantOperatingHours
{
    public Guid Id { get; set; }
    public Guid ProviderLocationId { get; set; }
    public ProviderType ProviderType { get; set; } = ProviderType.RESTAURANT;
    public short DayOfWeek { get; set; }
    public TimeOnly? OpenTime { get; set; }
    public TimeOnly? CloseTime { get; set; }
    public bool IsClosed { get; set; }

    public ProviderLocation ProviderLocation { get; set; } = null!;
}
