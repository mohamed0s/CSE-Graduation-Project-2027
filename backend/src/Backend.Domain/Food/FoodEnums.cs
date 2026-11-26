namespace Backend.Domain.Food;

public enum RestaurantOperatingMode
{
    MENU_ONLY,
    ORDER_ENABLED
}

public enum FoodOrderStatus
{
    PENDING,
    ACCEPTED,
    PREPARING,
    OUT_FOR_DELIVERY,
    READY_FOR_PICKUP,
    DELIVERED,
    COMPLETED,
    REJECTED,
    CANCELLED
}

public enum FoodFulfillmentType
{
    DELIVERY,
    PICKUP
}

public enum PaymentMethod
{
    CASH_ON_DELIVERY
}

public enum PaymentStatus
{
    PENDING,
    PAID,
    REFUNDED
}
