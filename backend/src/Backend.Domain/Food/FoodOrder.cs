using Backend.Domain.Common;
using Backend.Domain.Identity;
using Backend.Domain.Providers;

namespace Backend.Domain.Food;

public class FoodOrder : AuditableEntity
{
    public string OrderNumber { get; set; } = string.Empty;
    public Guid CustomerId { get; set; }
    public Guid RestaurantId { get; set; }
    public Guid ProviderLocationId { get; set; }
    public FoodOrderStatus Status { get; set; } = FoodOrderStatus.PENDING;
    public FoodFulfillmentType FulfillmentType { get; set; } = FoodFulfillmentType.DELIVERY;
    public PaymentMethod PaymentMethod { get; set; } = PaymentMethod.CASH_ON_DELIVERY;
    public PaymentStatus PaymentStatus { get; set; } = PaymentStatus.PENDING;
    public decimal Subtotal { get; set; }
    public decimal DeliveryFee { get; set; }
    public decimal TotalAmount { get; set; }
    public string? CustomerNotes { get; set; }
    public string? RejectionReason { get; set; }
    public string? CancellationReason { get; set; }
    public DateTimeOffset? CancelledAt { get; set; }
    public uint RowVersion { get; set; }

    public User Customer { get; set; } = null!;
    public Restaurant Restaurant { get; set; } = null!;
    public ProviderLocation ProviderLocation { get; set; } = null!;
    public ICollection<FoodOrderItem> Items { get; set; } = new List<FoodOrderItem>();
    public ICollection<FoodOrderStatusHistory> StatusHistory { get; set; } = new List<FoodOrderStatusHistory>();
    public FoodOrderDeliveryInfo? DeliveryInfo { get; set; }
}
