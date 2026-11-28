using Backend.Domain.Food;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class FoodOrderDeliveryInfoConfiguration : IEntityTypeConfiguration<FoodOrderDeliveryInfo>
{
    public void Configure(EntityTypeBuilder<FoodOrderDeliveryInfo> builder)
    {
        builder.ToTable("food_order_delivery_info");
        builder.HasKey(x => x.Id).HasName("pk_food_order_delivery_info");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.FoodOrderId).HasColumnName("food_order_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.RecipientName).HasColumnName("recipient_name").HasColumnType("varchar(150)").HasMaxLength(150).IsRequired();
        builder.Property(x => x.RecipientPhone).HasColumnName("recipient_phone").HasColumnType("varchar(30)").HasMaxLength(30).IsRequired();
        builder.Property(x => x.AddressLine).HasColumnName("address_line").HasColumnType("text").IsRequired();
        builder.Property(x => x.City).HasColumnName("city").HasColumnType("varchar(100)").HasMaxLength(100).IsRequired();
        builder.Property(x => x.DeliveryInstructions).HasColumnName("delivery_instructions").HasColumnType("text");

        builder.HasIndex(x => x.FoodOrderId).IsUnique().HasDatabaseName("uq_food_order_delivery_info_food_order_id");

        builder.HasOne(x => x.FoodOrder)
            .WithOne(o => o.DeliveryInfo)
            .HasForeignKey<FoodOrderDeliveryInfo>(x => x.FoodOrderId)
            .HasConstraintName("fk_food_order_delivery_info_food_orders_food_order_id")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
