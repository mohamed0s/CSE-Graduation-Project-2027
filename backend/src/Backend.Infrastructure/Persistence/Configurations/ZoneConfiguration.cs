using Backend.Domain.Geography;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class ZoneConfiguration : IEntityTypeConfiguration<Zone>
{
    public void Configure(EntityTypeBuilder<Zone> builder)
    {
        builder.ToTable("zones", t =>
        {
            t.HasCheckConstraint("ck_zones_zone_type", "zone_type IN ('CITY','ZONE','NEIGHBORHOOD')");
            t.HasCheckConstraint("ck_zones_boundary_valid", "ST_IsValid(boundary)");
        });

        builder.HasKey(z => z.Id).HasName("pk_zones");

        builder.Property(z => z.Id)
            .HasColumnName("id")
            .HasColumnType("uuid")
            .HasDefaultValueSql("gen_random_uuid()");

        builder.Property(z => z.ParentZoneId)
            .HasColumnName("parent_zone_id")
            .HasColumnType("uuid");

        builder.Property(z => z.Name)
            .HasColumnName("name")
            .HasColumnType("varchar(120)")
            .HasMaxLength(120)
            .IsRequired();

        builder.Property(z => z.Slug)
            .HasColumnName("slug")
            .HasColumnType("varchar(120)")
            .HasMaxLength(120)
            .IsRequired();

        builder.Property(z => z.ZoneType)
            .HasColumnName("zone_type")
            .HasColumnType("varchar(30)")
            .HasMaxLength(30)
            .HasConversion<string>()
            .HasDefaultValue(ZoneType.ZONE)
            .IsRequired();

        builder.Property(z => z.Boundary)
            .HasColumnName("boundary")
            .HasColumnType("geometry(MultiPolygon, 4326)")
            .IsRequired();

        builder.Property(z => z.Centroid)
            .HasColumnName("centroid")
            .HasColumnType("geometry(Point, 4326)");

        builder.Property(z => z.IsActive)
            .HasColumnName("is_active")
            .HasColumnType("boolean")
            .HasDefaultValue(true)
            .IsRequired();

        builder.Property(z => z.CreatedAt)
            .HasColumnName("created_at")
            .HasColumnType("timestamptz")
            .HasDefaultValueSql("now()")
            .IsRequired();

        builder.Property(z => z.UpdatedAt)
            .HasColumnName("updated_at")
            .HasColumnType("timestamptz")
            .HasDefaultValueSql("now()")
            .IsRequired();

        builder.HasIndex(z => z.Slug)
            .IsUnique()
            .HasDatabaseName("uq_zones_slug");

        builder.HasIndex(z => z.Boundary)
            .HasMethod("gist")
            .HasDatabaseName("ix_zones_boundary");

        builder.HasIndex(z => new { z.ParentZoneId, z.IsActive })
            .HasDatabaseName("ix_zones_parent_zone_id_is_active");

        builder.HasOne(z => z.ParentZone)
            .WithMany(z => z.ChildZones)
            .HasForeignKey(z => z.ParentZoneId)
            .HasConstraintName("fk_zones_zones_parent_zone_id")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
