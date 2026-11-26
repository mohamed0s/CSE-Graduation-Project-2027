namespace Backend.Domain.Food;

public class FoodOrderItem
{
    public Guid Id { get; set; }
    public Guid FoodOrderId { get; set; }
    public Guid? MenuItemId { get; set; }
    public string ItemNameSnapshot { get; set; } = string.Empty;
    public decimal UnitPriceSnapshot { get; set; }
    public int Quantity { get; set; }
    public decimal LineTotal { get; set; }

    public FoodOrder FoodOrder { get; set; } = null!;
    public MenuItem? MenuItem { get; set; }
}
