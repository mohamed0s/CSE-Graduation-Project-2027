using Backend.Domain.Food;
using Backend.Domain.Providers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class RestaurantConfiguration : IEntityTypeConfiguration<Restaurant>
{
    public void Configure(EntityTypeBuilder<Restaurant> builder)
    {
        builder.ToTable("restaurants", t =>
        {
            t.HasCheckConstraint("ck_restaurants_type", "provider_type = 'RESTAURANT'");
            t.HasCheckConstraint("ck_restaurants_operating_mode", "operating_mode IN ('MENU_ONLY','ORDER_ENABLED')");
            t.HasCheckConstraint("ck_restaurants_average_rating", "average_rating >= 0 AND average_rating <= 5");
        });

        builder.HasKey(x => x.ProviderId).HasName("pk_restaurants");

        builder.Property(x => x.ProviderId).HasColumnName("provider_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ProviderType).HasColumnName("provider_type").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>().HasDefaultValue(ProviderType.RESTAURANT).IsRequired();
        builder.Property(x => x.Name).HasColumnName("name").HasColumnType("varchar(150)").HasMaxLength(150).IsRequired();
        builder.Property(x => x.Description).HasColumnName("description").HasColumnType("text");
        builder.Property(x => x.CuisineType).HasColumnName("cuisine_type").HasColumnType("varchar(80)").HasMaxLength(80);
        builder.Property(x => x.OperatingMode).HasColumnName("operating_mode").HasColumnType("varchar(20)").HasMaxLength(20).HasConversion<string>().HasDefaultValue(RestaurantOperatingMode.MENU_ONLY).IsRequired();
        builder.Property(x => x.AverageRating).HasColumnName("average_rating").HasColumnType("numeric(3,2)").HasDefaultValue(0.00m).IsRequired();
        builder.Property(x => x.TotalReviews).HasColumnName("total_reviews").HasColumnType("integer").HasDefaultValue(0).IsRequired();
        builder.Property(x => x.IsActive).HasColumnName("is_active").HasColumnType("boolean").HasDefaultValue(true).IsRequired();
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => new { x.OperatingMode, x.IsActive }).HasDatabaseName("ix_restaurants_operating_mode_is_active");

        builder.HasOne(x => x.Provider)
            .WithOne()
            .HasForeignKey<Restaurant>(x => new { x.ProviderId, x.ProviderType })
            .HasPrincipalKey<Provider>(p => new { p.Id, p.ProviderType })
            .HasConstraintName("fk_restaurants_provider_type")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
