using Backend.Domain.Communication;
using Backend.Domain.Food;
using Backend.Domain.Geography;
using Backend.Domain.Healthcare;
using Backend.Domain.Identity;
using Backend.Domain.Marketplace;
using Backend.Domain.Providers;
using Backend.Domain.Reviews;
using Microsoft.EntityFrameworkCore;

namespace Backend.Application.Common.Interfaces;

/// <summary>
/// Abstraction over the PostgreSQL database context for Application services (32 tables).
/// </summary>
public interface IAppDbContext
{
    DbSet<User> Users { get; }
    DbSet<Role> Roles { get; }
    DbSet<UserRole> UserRoles { get; }
    DbSet<RefreshToken> RefreshTokens { get; }
    DbSet<CustomerProfile> CustomerProfiles { get; }

    DbSet<Zone> Zones { get; }
    DbSet<Provider> Providers { get; }
    DbSet<ProviderLocation> ProviderLocations { get; }

    DbSet<ServiceCategory> ServiceCategories { get; }
    DbSet<Service> Services { get; }
    DbSet<GeneralProvider> GeneralProviders { get; }
    DbSet<ServiceRequest> ServiceRequests { get; }
    DbSet<ServiceRequestStatusHistory> ServiceRequestStatusHistories { get; }

    DbSet<Restaurant> Restaurants { get; }
    DbSet<RestaurantLocationSettings> RestaurantLocationSettings { get; }
    DbSet<RestaurantOperatingHours> RestaurantOperatingHours { get; }
    DbSet<MenuCategory> MenuCategories { get; }
    DbSet<MenuItem> MenuItems { get; }
    DbSet<FoodOrder> FoodOrders { get; }
    DbSet<FoodOrderItem> FoodOrderItems { get; }
    DbSet<FoodOrderStatusHistory> FoodOrderStatusHistories { get; }
    DbSet<FoodOrderDeliveryInfo> FoodOrderDeliveryInfos { get; }

    DbSet<MedicalSpecialty> MedicalSpecialties { get; }
    DbSet<HealthcareProvider> HealthcareProviders { get; }
    DbSet<HealthcareLocationSettings> HealthcareLocationSettings { get; }
    DbSet<ProviderSchedule> ProviderSchedules { get; }
    DbSet<ScheduleException> ScheduleExceptions { get; }
    DbSet<HealthcareAppointment> HealthcareAppointments { get; }
    DbSet<AppointmentStatusHistory> AppointmentStatusHistories { get; }

    DbSet<Notification> Notifications { get; }
    DbSet<NotificationPreference> NotificationPreferences { get; }
    DbSet<Review> Reviews { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
