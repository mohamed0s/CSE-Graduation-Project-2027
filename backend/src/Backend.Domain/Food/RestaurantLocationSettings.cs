using Backend.Domain.Providers;

namespace Backend.Domain.Food;

public class RestaurantLocationSettings
{
    public Guid Id { get; set; }
    public Guid ProviderLocationId { get; set; }
    public ProviderType ProviderType { get; set; } = ProviderType.RESTAURANT;
    public bool IsAcceptingOrders { get; set; }
    public decimal DeliveryFee { get; set; }
    public int? EstimatedDeliveryMinutes { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }

    public ProviderLocation ProviderLocation { get; set; } = null!;
}
