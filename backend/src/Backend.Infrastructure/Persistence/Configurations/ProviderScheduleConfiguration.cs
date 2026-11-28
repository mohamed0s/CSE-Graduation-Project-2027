using Backend.Domain.Healthcare;
using Backend.Domain.Providers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class ProviderScheduleConfiguration : IEntityTypeConfiguration<ProviderSchedule>
{
    public void Configure(EntityTypeBuilder<ProviderSchedule> builder)
    {
        builder.ToTable("provider_schedules", t =>
        {
            t.HasCheckConstraint("ck_provider_schedules_type", "provider_type = 'HEALTHCARE'");
            t.HasCheckConstraint("ck_provider_schedules_day_of_week", "day_of_week >= 0 AND day_of_week <= 6");
            t.HasCheckConstraint("ck_provider_schedules_times", "start_time < end_time");
        });

        builder.HasKey(x => x.Id).HasName("pk_provider_schedules");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.ProviderLocationId).HasColumnName("provider_location_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ProviderType).HasColumnName("provider_type").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>().HasDefaultValue(ProviderType.HEALTHCARE).IsRequired();
        builder.Property(x => x.DayOfWeek).HasColumnName("day_of_week").HasColumnType("smallint").IsRequired();
        builder.Property(x => x.StartTime).HasColumnName("start_time").HasColumnType("time").IsRequired();
        builder.Property(x => x.EndTime).HasColumnName("end_time").HasColumnType("time").IsRequired();
        builder.Property(x => x.IsActive).HasColumnName("is_active").HasColumnType("boolean").HasDefaultValue(true).IsRequired();

        builder.HasIndex(x => new { x.ProviderLocationId, x.DayOfWeek, x.IsActive }).HasDatabaseName("ix_provider_schedules_location_day_active");

        builder.HasOne(x => x.ProviderLocation)
            .WithMany()
            .HasForeignKey(x => new { x.ProviderLocationId, x.ProviderType })
            .HasPrincipalKey(pl => new { pl.Id, pl.ProviderType })
            .HasConstraintName("fk_provider_schedules_provider_location_type")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
