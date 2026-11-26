using Backend.Domain.Healthcare;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class HealthcareAppointmentConfiguration : IEntityTypeConfiguration<HealthcareAppointment>
{
    public void Configure(EntityTypeBuilder<HealthcareAppointment> builder)
    {
        builder.ToTable("healthcare_appointments", t =>
        {
            t.HasCheckConstraint(
                "ck_healthcare_appointments_status",
                "status IN ('PENDING','CONFIRMED','COMPLETED','REJECTED','CANCELLED','NO_SHOW')");
            t.HasCheckConstraint("ck_healthcare_appointments_range", "end_at > start_at AND duration_minutes > 0");
            t.HasCheckConstraint("ck_healthcare_appointments_fee", "consultation_fee_snapshot >= 0");
        });

        builder.HasKey(x => x.Id).HasName("pk_healthcare_appointments");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.CustomerId).HasColumnName("customer_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.HealthcareProviderId).HasColumnName("healthcare_provider_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ProviderLocationId).HasColumnName("provider_location_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.StartAt).HasColumnName("start_at").HasColumnType("timestamptz").IsRequired();
        builder.Property(x => x.EndAt).HasColumnName("end_at").HasColumnType("timestamptz").IsRequired();
        builder.Property(x => x.DurationMinutes).HasColumnName("duration_minutes").HasColumnType("integer").IsRequired();
        builder.Property(x => x.ConsultationFeeSnapshot).HasColumnName("consultation_fee_snapshot").HasColumnType("numeric(12,2)").IsRequired();
        builder.Property(x => x.Status).HasColumnName("status").HasColumnType("varchar(20)").HasMaxLength(20).HasConversion<string>().HasDefaultValue(AppointmentStatus.PENDING).IsRequired();
        builder.Property(x => x.PatientNotes).HasColumnName("patient_notes").HasColumnType("text");
        builder.Property(x => x.RejectionReason).HasColumnName("rejection_reason").HasColumnType("text");
        builder.Property(x => x.CancellationReason).HasColumnName("cancellation_reason").HasColumnType("text");
        builder.Property(x => x.CancelledAt).HasColumnName("cancelled_at").HasColumnType("timestamptz");
        builder.Property(x => x.CancelledByUserId).HasColumnName("cancelled_by_user_id").HasColumnType("uuid");
        builder.Property(x => x.RescheduledFromAppointmentId).HasColumnName("rescheduled_from_appointment_id").HasColumnType("uuid");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.RowVersion).IsRowVersion();

        builder.HasIndex(x => new { x.CustomerId, x.StartAt }).HasDatabaseName("ix_healthcare_appointments_customer_id_start_at");
        builder.HasIndex(x => new { x.ProviderLocationId, x.StartAt }).HasDatabaseName("ix_healthcare_appointments_provider_location_id_start_at");

        builder.HasOne(x => x.Customer)
            .WithMany()
            .HasForeignKey(x => x.CustomerId)
            .HasConstraintName("fk_healthcare_appointments_users_customer_id")
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.HealthcareProvider)
            .WithMany(hp => hp.Appointments)
            .HasForeignKey(x => x.HealthcareProviderId)
            .HasConstraintName("fk_healthcare_appointments_healthcare_providers_id")
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.ProviderLocation)
            .WithMany()
            .HasForeignKey(x => new { x.ProviderLocationId, x.HealthcareProviderId })
            .HasPrincipalKey(pl => new { pl.Id, pl.ProviderId })
            .HasConstraintName("fk_healthcare_appointments_provider_location_owner")
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.CancelledByUser)
            .WithMany()
            .HasForeignKey(x => x.CancelledByUserId)
            .HasConstraintName("fk_healthcare_appointments_users_cancelled_by_user_id")
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasOne(x => x.RescheduledFromAppointment)
            .WithMany()
            .HasForeignKey(x => x.RescheduledFromAppointmentId)
            .HasConstraintName("fk_healthcare_appointments_rescheduled_from_id")
            .OnDelete(DeleteBehavior.SetNull);
    }
}
