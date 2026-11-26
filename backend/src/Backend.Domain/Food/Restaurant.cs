using Backend.Domain.Providers;

namespace Backend.Domain.Food;

/// <summary>
/// Specialized Restaurant profile (1-to-1 with Provider where ProviderType == RESTAURANT).
/// </summary>
public class Restaurant
{
    public Guid ProviderId { get; set; }
    public ProviderType ProviderType { get; set; } = ProviderType.RESTAURANT;
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? CuisineType { get; set; }
    public RestaurantOperatingMode OperatingMode { get; set; } = RestaurantOperatingMode.MENU_ONLY;
    public decimal AverageRating { get; set; }
    public int TotalReviews { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }

    public Provider Provider { get; set; } = null!;
    public ICollection<MenuCategory> MenuCategories { get; set; } = new List<MenuCategory>();
    public ICollection<MenuItem> MenuItems { get; set; } = new List<MenuItem>();
    public ICollection<FoodOrder> Orders { get; set; } = new List<FoodOrder>();
}
