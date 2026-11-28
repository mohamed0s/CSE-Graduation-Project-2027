using Backend.Domain.Identity;

namespace Backend.Domain.Food;

public class FoodOrderStatusHistory
{
    public Guid Id { get; set; }
    public Guid FoodOrderId { get; set; }
    public FoodOrderStatus? FromStatus { get; set; }
    public FoodOrderStatus ToStatus { get; set; }
    public Guid ChangedByUserId { get; set; }
    public string? Note { get; set; }
    public DateTimeOffset CreatedAt { get; set; }

    public FoodOrder FoodOrder { get; set; } = null!;
    public User ChangedByUser { get; set; } = null!;
}
