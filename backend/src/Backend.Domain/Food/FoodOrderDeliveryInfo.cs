namespace Backend.Domain.Food;

public class FoodOrderDeliveryInfo
{
    public Guid Id { get; set; }
    public Guid FoodOrderId { get; set; }
    public string RecipientName { get; set; } = string.Empty;
    public string RecipientPhone { get; set; } = string.Empty;
    public string AddressLine { get; set; } = string.Empty;
    public string City { get; set; } = string.Empty;
    public string? DeliveryInstructions { get; set; }

    public FoodOrder FoodOrder { get; set; } = null!;
}
