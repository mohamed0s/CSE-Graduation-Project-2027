using Backend.Domain.Healthcare;
using Backend.Domain.Providers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class HealthcareLocationSettingsConfiguration : IEntityTypeConfiguration<HealthcareLocationSettings>
{
    public void Configure(EntityTypeBuilder<HealthcareLocationSettings> builder)
    {
        builder.ToTable("healthcare_location_settings", t =>
        {
            t.HasCheckConstraint("ck_healthcare_location_settings_type", "provider_type = 'HEALTHCARE'");
            t.HasCheckConstraint("ck_healthcare_location_settings_fee", "consultation_fee >= 0");
            t.HasCheckConstraint("ck_healthcare_location_settings_slot_duration", "slot_duration_minutes >= 5 AND slot_duration_minutes <= 240");
        });

        builder.HasKey(x => x.Id).HasName("pk_healthcare_location_settings");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.ProviderLocationId).HasColumnName("provider_location_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ProviderType).HasColumnName("provider_type").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>().HasDefaultValue(ProviderType.HEALTHCARE).IsRequired();
        builder.Property(x => x.ConsultationFee).HasColumnName("consultation_fee").HasColumnType("numeric(12,2)").HasDefaultValue(0.00m).IsRequired();
        builder.Property(x => x.SlotDurationMinutes).HasColumnName("slot_duration_minutes").HasColumnType("integer").HasDefaultValue(30).IsRequired();
        builder.Property(x => x.RequiresApproval).HasColumnName("requires_approval").HasColumnType("boolean").HasDefaultValue(true).IsRequired();
        builder.Property(x => x.Timezone).HasColumnName("timezone").HasColumnType("varchar(64)").HasMaxLength(64).HasDefaultValue("Africa/Cairo").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => x.ProviderLocationId).IsUnique().HasDatabaseName("uq_healthcare_location_settings_provider_location_id");

        builder.HasOne(x => x.ProviderLocation)
            .WithOne()
            .HasForeignKey<HealthcareLocationSettings>(x => new { x.ProviderLocationId, x.ProviderType })
            .HasPrincipalKey<ProviderLocation>(pl => new { pl.Id, pl.ProviderType })
            .HasConstraintName("fk_healthcare_location_settings_provider_location_type")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
