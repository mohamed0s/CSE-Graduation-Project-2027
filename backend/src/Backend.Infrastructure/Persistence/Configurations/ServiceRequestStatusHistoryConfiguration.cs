using Backend.Domain.Marketplace;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class ServiceRequestStatusHistoryConfiguration : IEntityTypeConfiguration<ServiceRequestStatusHistory>
{
    public void Configure(EntityTypeBuilder<ServiceRequestStatusHistory> builder)
    {
        builder.ToTable("service_request_status_history");
        builder.HasKey(x => x.Id).HasName("pk_service_request_status_history");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.ServiceRequestId).HasColumnName("service_request_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.FromStatus).HasColumnName("from_status").HasColumnType("varchar(20)").HasMaxLength(20).HasConversion<string>();
        builder.Property(x => x.ToStatus).HasColumnName("to_status").HasColumnType("varchar(20)").HasMaxLength(20).HasConversion<string>().IsRequired();
        builder.Property(x => x.ChangedByUserId).HasColumnName("changed_by_user_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.Note).HasColumnName("note").HasColumnType("text");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => x.ServiceRequestId).HasDatabaseName("ix_service_request_status_history_service_request_id");

        builder.HasOne(x => x.ServiceRequest)
            .WithMany(sr => sr.StatusHistory)
            .HasForeignKey(x => x.ServiceRequestId)
            .HasConstraintName("fk_service_request_status_history_service_requests_id")
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ChangedByUser)
            .WithMany()
            .HasForeignKey(x => x.ChangedByUserId)
            .HasConstraintName("fk_service_request_status_history_users_changed_by_user_id")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
