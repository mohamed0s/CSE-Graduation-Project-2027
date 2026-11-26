using Backend.Domain.Food;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class MenuCategoryConfiguration : IEntityTypeConfiguration<MenuCategory>
{
    public void Configure(EntityTypeBuilder<MenuCategory> builder)
    {
        builder.ToTable("menu_categories");
        builder.HasKey(x => x.Id).HasName("pk_menu_categories");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.RestaurantId).HasColumnName("restaurant_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.Name).HasColumnName("name").HasColumnType("varchar(100)").HasMaxLength(100).IsRequired();
        builder.Property(x => x.DisplayOrder).HasColumnName("display_order").HasColumnType("integer").HasDefaultValue(0).IsRequired();
        builder.Property(x => x.IsActive).HasColumnName("is_active").HasColumnType("boolean").HasDefaultValue(true).IsRequired();
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => new { x.RestaurantId, x.DisplayOrder }).HasDatabaseName("ix_menu_categories_restaurant_id_display_order");

        builder.HasOne(x => x.Restaurant)
            .WithMany(r => r.MenuCategories)
            .HasForeignKey(x => x.RestaurantId)
            .HasConstraintName("fk_menu_categories_restaurants_restaurant_id")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
