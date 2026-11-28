using Backend.Domain.Food;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class MenuItemConfiguration : IEntityTypeConfiguration<MenuItem>
{
    public void Configure(EntityTypeBuilder<MenuItem> builder)
    {
        builder.ToTable("menu_items", t =>
        {
            t.HasCheckConstraint("ck_menu_items_price", "price >= 0");
        });

        builder.HasKey(x => x.Id).HasName("pk_menu_items");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.RestaurantId).HasColumnName("restaurant_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.MenuCategoryId).HasColumnName("menu_category_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.Name).HasColumnName("name").HasColumnType("varchar(150)").HasMaxLength(150).IsRequired();
        builder.Property(x => x.Description).HasColumnName("description").HasColumnType("text");
        builder.Property(x => x.Price).HasColumnName("price").HasColumnType("numeric(12,2)").IsRequired();
        builder.Property(x => x.ImageUrl).HasColumnName("image_url").HasColumnType("text");
        builder.Property(x => x.IsAvailable).HasColumnName("is_available").HasColumnType("boolean").HasDefaultValue(true).IsRequired();
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => new { x.RestaurantId, x.MenuCategoryId, x.IsAvailable }).HasDatabaseName("ix_menu_items_restaurant_category_available");

        builder.HasOne(x => x.Restaurant)
            .WithMany(r => r.MenuItems)
            .HasForeignKey(x => x.RestaurantId)
            .HasConstraintName("fk_menu_items_restaurants_restaurant_id")
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.MenuCategory)
            .WithMany(mc => mc.MenuItems)
            .HasForeignKey(x => new { x.MenuCategoryId, x.RestaurantId })
            .HasPrincipalKey(mc => new { mc.Id, mc.RestaurantId })
            .HasConstraintName("fk_menu_items_menu_category_restaurant")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
