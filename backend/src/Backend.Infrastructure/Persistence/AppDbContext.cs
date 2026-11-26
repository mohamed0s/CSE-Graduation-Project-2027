using Backend.Application.Common.Interfaces;
using Backend.Domain.Common;
using Backend.Domain.Communication;
using Backend.Domain.Food;
using Backend.Domain.Geography;
using Backend.Domain.Healthcare;
using Backend.Domain.Identity;
using Backend.Domain.Marketplace;
using Backend.Domain.Providers;
using Backend.Domain.Reviews;
using Microsoft.EntityFrameworkCore;

namespace Backend.Infrastructure.Persistence;

/// <summary>
/// Primary EF Core DbContext for FINDA (PostgreSQL + PostGIS, 32 tables).
/// </summary>
public class AppDbContext : DbContext, IAppDbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<UserRole> UserRoles => Set<UserRole>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<CustomerProfile> CustomerProfiles => Set<CustomerProfile>();

    public DbSet<Zone> Zones => Set<Zone>();
    public DbSet<Provider> Providers => Set<Provider>();
    public DbSet<ProviderLocation> ProviderLocations => Set<ProviderLocation>();

    public DbSet<ServiceCategory> ServiceCategories => Set<ServiceCategory>();
    public DbSet<Service> Services => Set<Service>();
    public DbSet<GeneralProvider> GeneralProviders => Set<GeneralProvider>();
    public DbSet<ServiceRequest> ServiceRequests => Set<ServiceRequest>();
    public DbSet<ServiceRequestStatusHistory> ServiceRequestStatusHistories => Set<ServiceRequestStatusHistory>();

    public DbSet<Restaurant> Restaurants => Set<Restaurant>();
    public DbSet<RestaurantLocationSettings> RestaurantLocationSettings => Set<RestaurantLocationSettings>();
    public DbSet<RestaurantOperatingHours> RestaurantOperatingHours => Set<RestaurantOperatingHours>();
    public DbSet<MenuCategory> MenuCategories => Set<MenuCategory>();
    public DbSet<MenuItem> MenuItems => Set<MenuItem>();
    public DbSet<FoodOrder> FoodOrders => Set<FoodOrder>();
    public DbSet<FoodOrderItem> FoodOrderItems => Set<FoodOrderItem>();
    public DbSet<FoodOrderStatusHistory> FoodOrderStatusHistories => Set<FoodOrderStatusHistory>();
    public DbSet<FoodOrderDeliveryInfo> FoodOrderDeliveryInfos => Set<FoodOrderDeliveryInfo>();

    public DbSet<MedicalSpecialty> MedicalSpecialties => Set<MedicalSpecialty>();
    public DbSet<HealthcareProvider> HealthcareProviders => Set<HealthcareProvider>();
    public DbSet<HealthcareLocationSettings> HealthcareLocationSettings => Set<HealthcareLocationSettings>();
    public DbSet<ProviderSchedule> ProviderSchedules => Set<ProviderSchedule>();
    public DbSet<ScheduleException> ScheduleExceptions => Set<ScheduleException>();
    public DbSet<HealthcareAppointment> HealthcareAppointments => Set<HealthcareAppointment>();
    public DbSet<AppointmentStatusHistory> AppointmentStatusHistories => Set<AppointmentStatusHistory>();

    public DbSet<Notification> Notifications => Set<Notification>();
    public DbSet<NotificationPreference> NotificationPreferences => Set<NotificationPreference>();
    public DbSet<Review> Reviews => Set<Review>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.HasPostgresExtension("postgis");
        modelBuilder.HasPostgresExtension("btree_gist");

        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        var now = DateTimeOffset.UtcNow;

        foreach (var entry in ChangeTracker.Entries<AuditableEntity>())
        {
            if (entry.State == EntityState.Added)
            {
                if (entry.Entity.CreatedAt == default)
                {
                    entry.Entity.CreatedAt = now;
                }
                entry.Entity.UpdatedAt = now;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = now;
            }
        }

        return base.SaveChangesAsync(cancellationToken);
    }
}
