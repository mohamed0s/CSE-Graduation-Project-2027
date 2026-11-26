using Backend.Domain.Providers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class ProviderLocationConfiguration : IEntityTypeConfiguration<ProviderLocation>
{
    public void Configure(EntityTypeBuilder<ProviderLocation> builder)
    {
        builder.ToTable("provider_locations", t =>
        {
            t.HasCheckConstraint(
                "ck_provider_locations_type",
                "provider_type IN ('GENERAL','RESTAURANT','HEALTHCARE')");
        });

        builder.HasKey(pl => pl.Id).HasName("pk_provider_locations");

        builder.HasAlternateKey(pl => new { pl.Id, pl.ProviderId })
            .HasName("uq_provider_locations_id_provider");

        builder.HasAlternateKey(pl => new { pl.Id, pl.ProviderType })
            .HasName("uq_provider_locations_id_type");

        builder.Property(pl => pl.Id)
            .HasColumnName("id")
            .HasColumnType("uuid")
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(pl => pl.ProviderId)
            .HasColumnName("provider_id")
            .HasColumnType("uuid")
            .IsRequired();

        builder.Property(pl => pl.ProviderType)
            .HasColumnName("provider_type")
            .HasColumnType("varchar(30)")
            .HasMaxLength(30)
            .HasConversion<string>()
            .IsRequired();

        builder.Property(pl => pl.ZoneId)
            .HasColumnName("zone_id")
            .HasColumnType("uuid")
            .IsRequired();

        builder.Property(pl => pl.BranchName)
            .HasColumnName("branch_name")
            .HasColumnType("varchar(150)")
            .HasMaxLength(150)
            .IsRequired();

        builder.Property(pl => pl.AddressLine)
            .HasColumnName("address_line")
            .HasColumnType("text")
            .IsRequired();

        builder.Property(pl => pl.Location)
            .HasColumnName("location")
            .HasColumnType("geometry(Point, 4326)")
            .IsRequired();

        builder.Property(pl => pl.PhoneNumber)
            .HasColumnName("phone_number")
            .HasColumnType("varchar(30)")
            .HasMaxLength(30);

        builder.Property(pl => pl.IsActive)
            .HasColumnName("is_active")
            .HasColumnType("boolean")
            .HasDefaultValue(true)
            .IsRequired();

        builder.Property(pl => pl.CreatedAt)
            .HasColumnName("created_at")
            .HasColumnType("timestamptz")
            .HasDefaultValueSql("now()")
            .IsRequired();

        builder.Property(pl => pl.UpdatedAt)
            .HasColumnName("updated_at")
            .HasColumnType("timestamptz")
            .HasDefaultValueSql("now()")
            .IsRequired();

        // Supports ST_Covers(z.boundary, pl.location) on geometry(Point, 4326).
        // Note: When generating the initial migration, also add the geography expression index:
        // CREATE INDEX ix_provider_locations_location_geog ON provider_locations USING gist ((location::geography));
        builder.HasIndex(pl => pl.Location)
            .HasMethod("gist")
            .HasDatabaseName("ix_provider_locations_location");

        builder.HasIndex(pl => new { pl.ZoneId, pl.ProviderType, pl.IsActive })
            .HasDatabaseName("ix_provider_locations_zone_id_provider_type_is_active");

        builder.HasIndex(pl => new { pl.ProviderId, pl.IsActive })
            .HasDatabaseName("ix_provider_locations_provider_id_is_active");

        builder.HasOne(pl => pl.Provider)
            .WithMany(p => p.Locations)
            .HasForeignKey(pl => new { pl.ProviderId, pl.ProviderType })
            .HasPrincipalKey(p => new { p.Id, p.ProviderType })
            .HasConstraintName("fk_provider_locations_provider_type")
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(pl => pl.Zone)
            .WithMany(z => z.ProviderLocations)
            .HasForeignKey(pl => pl.ZoneId)
            .HasConstraintName("fk_provider_locations_zones_zone_id")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
