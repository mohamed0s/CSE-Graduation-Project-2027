namespace Backend.Domain.Identity;

public static class RoleNames
{
    public const string Customer = "CUSTOMER";
    public const string GeneralProvider = "GENERAL_PROVIDER";
    public const string RestaurantProvider = "RESTAURANT_PROVIDER";
    public const string HealthcareProvider = "HEALTHCARE_PROVIDER";
    public const string Admin = "ADMIN";

    public static readonly string[] All =
    [
        Customer,
        GeneralProvider,
        RestaurantProvider,
        HealthcareProvider,
        Admin
    ];
}
