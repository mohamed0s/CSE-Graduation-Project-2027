using Backend.Domain.Food;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class FoodOrderStatusHistoryConfiguration : IEntityTypeConfiguration<FoodOrderStatusHistory>
{
    public void Configure(EntityTypeBuilder<FoodOrderStatusHistory> builder)
    {
        builder.ToTable("food_order_status_history");
        builder.HasKey(x => x.Id).HasName("pk_food_order_status_history");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.FoodOrderId).HasColumnName("food_order_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.FromStatus).HasColumnName("from_status").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>();
        builder.Property(x => x.ToStatus).HasColumnName("to_status").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>().IsRequired();
        builder.Property(x => x.ChangedByUserId).HasColumnName("changed_by_user_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.Note).HasColumnName("note").HasColumnType("text");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => x.FoodOrderId).HasDatabaseName("ix_food_order_status_history_food_order_id");

        builder.HasOne(x => x.FoodOrder)
            .WithMany(o => o.StatusHistory)
            .HasForeignKey(x => x.FoodOrderId)
            .HasConstraintName("fk_food_order_status_history_food_orders_food_order_id")
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ChangedByUser)
            .WithMany()
            .HasForeignKey(x => x.ChangedByUserId)
            .HasConstraintName("fk_food_order_status_history_users_changed_by_user_id")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
