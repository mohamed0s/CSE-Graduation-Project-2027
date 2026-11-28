using Backend.Domain.Food;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class FoodOrderItemConfiguration : IEntityTypeConfiguration<FoodOrderItem>
{
    public void Configure(EntityTypeBuilder<FoodOrderItem> builder)
    {
        builder.ToTable("food_order_items", t =>
        {
            t.HasCheckConstraint("ck_food_order_items_quantity", "quantity > 0");
            t.HasCheckConstraint("ck_food_order_items_totals", "unit_price_snapshot >= 0 AND line_total = unit_price_snapshot * quantity");
        });

        builder.HasKey(x => x.Id).HasName("pk_food_order_items");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.FoodOrderId).HasColumnName("food_order_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.MenuItemId).HasColumnName("menu_item_id").HasColumnType("uuid");
        builder.Property(x => x.ItemNameSnapshot).HasColumnName("item_name_snapshot").HasColumnType("varchar(150)").HasMaxLength(150).IsRequired();
        builder.Property(x => x.UnitPriceSnapshot).HasColumnName("unit_price_snapshot").HasColumnType("numeric(12,2)").IsRequired();
        builder.Property(x => x.Quantity).HasColumnName("quantity").HasColumnType("integer").IsRequired();
        builder.Property(x => x.LineTotal).HasColumnName("line_total").HasColumnType("numeric(12,2)").IsRequired();

        builder.HasIndex(x => x.FoodOrderId).HasDatabaseName("ix_food_order_items_food_order_id");

        builder.HasOne(x => x.FoodOrder)
            .WithMany(o => o.Items)
            .HasForeignKey(x => x.FoodOrderId)
            .HasConstraintName("fk_food_order_items_food_orders_food_order_id")
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.MenuItem)
            .WithMany()
            .HasForeignKey(x => x.MenuItemId)
            .HasConstraintName("fk_food_order_items_menu_items_menu_item_id")
            .OnDelete(DeleteBehavior.SetNull);
    }
}
