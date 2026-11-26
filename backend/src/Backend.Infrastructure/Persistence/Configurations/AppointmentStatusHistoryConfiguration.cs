using Backend.Domain.Healthcare;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class AppointmentStatusHistoryConfiguration : IEntityTypeConfiguration<AppointmentStatusHistory>
{
    public void Configure(EntityTypeBuilder<AppointmentStatusHistory> builder)
    {
        builder.ToTable("appointment_status_history");
        builder.HasKey(x => x.Id).HasName("pk_appointment_status_history");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.AppointmentId).HasColumnName("appointment_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.FromStatus).HasColumnName("from_status").HasColumnType("varchar(20)").HasMaxLength(20).HasConversion<string>();
        builder.Property(x => x.ToStatus).HasColumnName("to_status").HasColumnType("varchar(20)").HasMaxLength(20).HasConversion<string>().IsRequired();
        builder.Property(x => x.ChangedByUserId).HasColumnName("changed_by_user_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.Note).HasColumnName("note").HasColumnType("text");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => x.AppointmentId).HasDatabaseName("ix_appointment_status_history_appointment_id");

        builder.HasOne(x => x.Appointment)
            .WithMany(a => a.StatusHistory)
            .HasForeignKey(x => x.AppointmentId)
            .HasConstraintName("fk_appointment_status_history_appointments_appointment_id")
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ChangedByUser)
            .WithMany()
            .HasForeignKey(x => x.ChangedByUserId)
            .HasConstraintName("fk_appointment_status_history_users_changed_by_user_id")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
