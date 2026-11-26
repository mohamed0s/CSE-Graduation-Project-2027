using Backend.Domain.Food;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class FoodOrderConfiguration : IEntityTypeConfiguration<FoodOrder>
{
    public void Configure(EntityTypeBuilder<FoodOrder> builder)
    {
        builder.ToTable("food_orders", t =>
        {
            t.HasCheckConstraint(
                "ck_food_orders_status",
                "status IN ('PENDING','ACCEPTED','PREPARING','OUT_FOR_DELIVERY','READY_FOR_PICKUP','DELIVERED','COMPLETED','REJECTED','CANCELLED')");
            t.HasCheckConstraint("ck_food_orders_fulfillment_type", "fulfillment_type IN ('DELIVERY','PICKUP')");
            t.HasCheckConstraint("ck_food_orders_totals", "subtotal >= 0 AND delivery_fee >= 0 AND total_amount = subtotal + delivery_fee");
        });

        builder.HasKey(x => x.Id).HasName("pk_food_orders");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.OrderNumber).HasColumnName("order_number").HasColumnType("varchar(30)").HasMaxLength(30).IsRequired();
        builder.Property(x => x.CustomerId).HasColumnName("customer_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.RestaurantId).HasColumnName("restaurant_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ProviderLocationId).HasColumnName("provider_location_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.Status).HasColumnName("status").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>().HasDefaultValue(FoodOrderStatus.PENDING).IsRequired();
        builder.Property(x => x.FulfillmentType).HasColumnName("fulfillment_type").HasColumnType("varchar(20)").HasMaxLength(20).HasConversion<string>().HasDefaultValue(FoodFulfillmentType.DELIVERY).IsRequired();
        builder.Property(x => x.PaymentMethod).HasColumnName("payment_method").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>().HasDefaultValue(PaymentMethod.CASH_ON_DELIVERY).IsRequired();
        builder.Property(x => x.PaymentStatus).HasColumnName("payment_status").HasColumnType("varchar(20)").HasMaxLength(20).HasConversion<string>().HasDefaultValue(PaymentStatus.PENDING).IsRequired();
        builder.Property(x => x.Subtotal).HasColumnName("subtotal").HasColumnType("numeric(12,2)").IsRequired();
        builder.Property(x => x.DeliveryFee).HasColumnName("delivery_fee").HasColumnType("numeric(12,2)").HasDefaultValue(0.00m).IsRequired();
        builder.Property(x => x.TotalAmount).HasColumnName("total_amount").HasColumnType("numeric(12,2)").IsRequired();
        builder.Property(x => x.CustomerNotes).HasColumnName("customer_notes").HasColumnType("text");
        builder.Property(x => x.RejectionReason).HasColumnName("rejection_reason").HasColumnType("text");
        builder.Property(x => x.CancellationReason).HasColumnName("cancellation_reason").HasColumnType("text");
        builder.Property(x => x.CancelledAt).HasColumnName("cancelled_at").HasColumnType("timestamptz");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.RowVersion).IsRowVersion();

        builder.HasIndex(x => x.OrderNumber).IsUnique().HasDatabaseName("uq_food_orders_order_number");
        builder.HasIndex(x => new { x.CustomerId, x.CreatedAt }).HasDatabaseName("ix_food_orders_customer_id_created_at");
        builder.HasIndex(x => new { x.ProviderLocationId, x.Status, x.CreatedAt }).HasDatabaseName("ix_food_orders_provider_location_status_created_at");

        builder.HasOne(x => x.Customer)
            .WithMany()
            .HasForeignKey(x => x.CustomerId)
            .HasConstraintName("fk_food_orders_users_customer_id")
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Restaurant)
            .WithMany(r => r.Orders)
            .HasForeignKey(x => x.RestaurantId)
            .HasConstraintName("fk_food_orders_restaurants_restaurant_id")
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.ProviderLocation)
            .WithMany()
            .HasForeignKey(x => new { x.ProviderLocationId, x.RestaurantId })
            .HasPrincipalKey(pl => new { pl.Id, pl.ProviderId })
            .HasConstraintName("fk_food_orders_provider_location_owner")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
