using Backend.Domain.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class CustomerProfileConfiguration : IEntityTypeConfiguration<CustomerProfile>
{
    public void Configure(EntityTypeBuilder<CustomerProfile> builder)
    {
        builder.ToTable("customer_profiles");

        builder.HasKey(cp => cp.Id).HasName("pk_customer_profiles");

        builder.Property(cp => cp.Id)
            .HasColumnName("id")
            .HasColumnType("uuid")
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(cp => cp.UserId)
            .HasColumnName("user_id")
            .HasColumnType("uuid")
            .IsRequired();

        builder.Property(cp => cp.SelectedZoneId)
            .HasColumnName("selected_zone_id")
            .HasColumnType("uuid");

        builder.Property(cp => cp.DefaultAddress)
            .HasColumnName("default_address")
            .HasColumnType("text");

        builder.Property(cp => cp.CreatedAt)
            .HasColumnName("created_at")
            .HasColumnType("timestamptz")
            .HasDefaultValueSql("now()")
            .IsRequired();

        builder.Property(cp => cp.UpdatedAt)
            .HasColumnName("updated_at")
            .HasColumnType("timestamptz")
            .HasDefaultValueSql("now()")
            .IsRequired();

        builder.HasIndex(cp => cp.UserId)
            .IsUnique()
            .HasDatabaseName("uq_customer_profiles_user_id");

        builder.HasIndex(cp => cp.SelectedZoneId)
            .HasDatabaseName("ix_customer_profiles_selected_zone_id");

        builder.HasOne(cp => cp.User)
            .WithOne(u => u.CustomerProfile)
            .HasForeignKey<CustomerProfile>(cp => cp.UserId)
            .HasConstraintName("fk_customer_profiles_users_user_id")
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(cp => cp.SelectedZone)
            .WithMany(z => z.SelectingCustomers)
            .HasForeignKey(cp => cp.SelectedZoneId)
            .HasConstraintName("fk_customer_profiles_zones_selected_zone_id")
            .OnDelete(DeleteBehavior.SetNull);
    }
}
