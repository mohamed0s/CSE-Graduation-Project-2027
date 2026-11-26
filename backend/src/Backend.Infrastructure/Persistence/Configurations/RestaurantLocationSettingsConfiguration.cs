using Backend.Domain.Food;
using Backend.Domain.Providers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class RestaurantLocationSettingsConfiguration : IEntityTypeConfiguration<RestaurantLocationSettings>
{
    public void Configure(EntityTypeBuilder<RestaurantLocationSettings> builder)
    {
        builder.ToTable("restaurant_location_settings", t =>
        {
            t.HasCheckConstraint("ck_restaurant_location_settings_type", "provider_type = 'RESTAURANT'");
            t.HasCheckConstraint("ck_restaurant_location_settings_delivery_fee", "delivery_fee >= 0");
        });

        builder.HasKey(x => x.Id).HasName("pk_restaurant_location_settings");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.ProviderLocationId).HasColumnName("provider_location_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ProviderType).HasColumnName("provider_type").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>().HasDefaultValue(ProviderType.RESTAURANT).IsRequired();
        builder.Property(x => x.IsAcceptingOrders).HasColumnName("is_accepting_orders").HasColumnType("boolean").HasDefaultValue(false).IsRequired();
        builder.Property(x => x.DeliveryFee).HasColumnName("delivery_fee").HasColumnType("numeric(12,2)").HasDefaultValue(0.00m).IsRequired();
        builder.Property(x => x.EstimatedDeliveryMinutes).HasColumnName("estimated_delivery_minutes").HasColumnType("integer");
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => x.ProviderLocationId).IsUnique().HasDatabaseName("uq_restaurant_location_settings_provider_location_id");

        builder.HasOne(x => x.ProviderLocation)
            .WithOne()
            .HasForeignKey<RestaurantLocationSettings>(x => new { x.ProviderLocationId, x.ProviderType })
            .HasPrincipalKey<ProviderLocation>(pl => new { pl.Id, pl.ProviderType })
            .HasConstraintName("fk_restaurant_location_settings_provider_location_type")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
