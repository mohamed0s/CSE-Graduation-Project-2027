using Backend.Domain.Food;
using Backend.Domain.Providers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class RestaurantOperatingHoursConfiguration : IEntityTypeConfiguration<RestaurantOperatingHours>
{
    public void Configure(EntityTypeBuilder<RestaurantOperatingHours> builder)
    {
        builder.ToTable("restaurant_operating_hours", t =>
        {
            t.HasCheckConstraint("ck_restaurant_operating_hours_type", "provider_type = 'RESTAURANT'");
            t.HasCheckConstraint("ck_restaurant_operating_hours_day_of_week", "day_of_week >= 0 AND day_of_week <= 6");
            t.HasCheckConstraint("ck_restaurant_operating_hours_times", "is_closed = true OR (open_time IS NOT NULL AND close_time IS NOT NULL AND open_time < close_time)");
        });

        builder.HasKey(x => x.Id).HasName("pk_restaurant_operating_hours");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.ProviderLocationId).HasColumnName("provider_location_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ProviderType).HasColumnName("provider_type").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>().HasDefaultValue(ProviderType.RESTAURANT).IsRequired();
        builder.Property(x => x.DayOfWeek).HasColumnName("day_of_week").HasColumnType("smallint").IsRequired();
        builder.Property(x => x.OpenTime).HasColumnName("open_time").HasColumnType("time");
        builder.Property(x => x.CloseTime).HasColumnName("close_time").HasColumnType("time");
        builder.Property(x => x.IsClosed).HasColumnName("is_closed").HasColumnType("boolean").HasDefaultValue(false).IsRequired();

        builder.HasIndex(x => new { x.ProviderLocationId, x.DayOfWeek }).IsUnique().HasDatabaseName("uq_restaurant_operating_hours_location_day");

        builder.HasOne(x => x.ProviderLocation)
            .WithMany()
            .HasForeignKey(x => new { x.ProviderLocationId, x.ProviderType })
            .HasPrincipalKey(pl => new { pl.Id, pl.ProviderType })
            .HasConstraintName("fk_restaurant_operating_hours_provider_location_type")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
