using Backend.Domain.Providers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class ProviderConfiguration : IEntityTypeConfiguration<Provider>
{
    public void Configure(EntityTypeBuilder<Provider> builder)
    {
        builder.ToTable("providers", t =>
        {
            t.HasCheckConstraint(
                "ck_providers_provider_type",
                "provider_type IN ('GENERAL','RESTAURANT','HEALTHCARE')");
        });

        builder.HasKey(p => p.Id).HasName("pk_providers");

        builder.HasAlternateKey(p => new { p.Id, p.ProviderType })
            .HasName("uq_providers_id_type");

        builder.Property(p => p.Id)
            .HasColumnName("id")
            .HasColumnType("uuid")
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(p => p.OwnerUserId)
            .HasColumnName("owner_user_id")
            .HasColumnType("uuid")
            .IsRequired();

        builder.Property(p => p.ProviderType)
            .HasColumnName("provider_type")
            .HasColumnType("varchar(30)")
            .HasMaxLength(30)
            .HasConversion<string>()
            .IsRequired();

        builder.Property(p => p.IsActive)
            .HasColumnName("is_active")
            .HasColumnType("boolean")
            .HasDefaultValue(true)
            .IsRequired();

        builder.Property(p => p.CreatedAt)
            .HasColumnName("created_at")
            .HasColumnType("timestamptz")
            .HasDefaultValueSql("now()")
            .IsRequired();

        builder.Property(p => p.UpdatedAt)
            .HasColumnName("updated_at")
            .HasColumnType("timestamptz")
            .HasDefaultValueSql("now()")
            .IsRequired();

        builder.HasIndex(p => p.OwnerUserId)
            .HasDatabaseName("ix_providers_owner_user_id");

        builder.HasOne(p => p.OwnerUser)
            .WithMany(u => u.OwnedProviders)
            .HasForeignKey(p => p.OwnerUserId)
            .HasConstraintName("fk_providers_users_owner_user_id")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
