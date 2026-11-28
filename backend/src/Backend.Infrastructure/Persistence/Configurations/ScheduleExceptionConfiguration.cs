using Backend.Domain.Healthcare;
using Backend.Domain.Providers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class ScheduleExceptionConfiguration : IEntityTypeConfiguration<ScheduleException>
{
    public void Configure(EntityTypeBuilder<ScheduleException> builder)
    {
        builder.ToTable("schedule_exceptions", t =>
        {
            t.HasCheckConstraint("ck_schedule_exceptions_type", "provider_type = 'HEALTHCARE'");
            t.HasCheckConstraint("ck_schedule_exceptions_times", "is_day_off = true OR (start_time IS NOT NULL AND end_time IS NOT NULL AND start_time < end_time)");
        });

        builder.HasKey(x => x.Id).HasName("pk_schedule_exceptions");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.ProviderLocationId).HasColumnName("provider_location_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ProviderType).HasColumnName("provider_type").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>().HasDefaultValue(ProviderType.HEALTHCARE).IsRequired();
        builder.Property(x => x.ExceptionDate).HasColumnName("exception_date").HasColumnType("date").IsRequired();
        builder.Property(x => x.IsDayOff).HasColumnName("is_day_off").HasColumnType("boolean").HasDefaultValue(true).IsRequired();
        builder.Property(x => x.StartTime).HasColumnName("start_time").HasColumnType("time");
        builder.Property(x => x.EndTime).HasColumnName("end_time").HasColumnType("time");
        builder.Property(x => x.Reason).HasColumnName("reason").HasColumnType("varchar(255)").HasMaxLength(255);
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => new { x.ProviderLocationId, x.ExceptionDate }).HasDatabaseName("ix_schedule_exceptions_location_date");

        builder.HasOne(x => x.ProviderLocation)
            .WithMany()
            .HasForeignKey(x => new { x.ProviderLocationId, x.ProviderType })
            .HasPrincipalKey(pl => new { pl.Id, pl.ProviderType })
            .HasConstraintName("fk_schedule_exceptions_provider_location_type")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
