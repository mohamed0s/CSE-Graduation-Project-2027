using Backend.Domain.Marketplace;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class ServiceRequestConfiguration : IEntityTypeConfiguration<ServiceRequest>
{
    public void Configure(EntityTypeBuilder<ServiceRequest> builder)
    {
        builder.ToTable("service_requests", t =>
        {
            t.HasCheckConstraint(
                "ck_service_requests_status",
                "status IN ('PENDING','ACCEPTED','IN_PROGRESS','COMPLETED','REJECTED','CANCELLED')");
            t.HasCheckConstraint("ck_service_requests_agreed_price", "agreed_price IS NULL OR agreed_price >= 0");
        });

        builder.HasKey(x => x.Id).HasName("pk_service_requests");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.CustomerId).HasColumnName("customer_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.GeneralProviderId).HasColumnName("general_provider_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ProviderLocationId).HasColumnName("provider_location_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ServiceId).HasColumnName("service_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.Status).HasColumnName("status").HasColumnType("varchar(20)").HasMaxLength(20).HasConversion<string>().HasDefaultValue(ServiceRequestStatus.PENDING).IsRequired();
        builder.Property(x => x.Description).HasColumnName("description").HasColumnType("text").IsRequired();
        builder.Property(x => x.ServiceAddress).HasColumnName("service_address").HasColumnType("text").IsRequired();
        builder.Property(x => x.PreferredDate).HasColumnName("preferred_date").HasColumnType("timestamptz");
        builder.Property(x => x.AgreedPrice).HasColumnName("agreed_price").HasColumnType("numeric(12,2)");
        builder.Property(x => x.RejectionReason).HasColumnName("rejection_reason").HasColumnType("text");
        builder.Property(x => x.CancellationReason).HasColumnName("cancellation_reason").HasColumnType("text");
        builder.Property(x => x.CancelledAt).HasColumnName("cancelled_at").HasColumnType("timestamptz");
        builder.Property(x => x.CancelledByUserId).HasColumnName("cancelled_by_user_id").HasColumnType("uuid");
        builder.Property(x => x.CompletedAt).HasColumnName("completed_at").HasColumnType("timestamptz");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.RowVersion).IsRowVersion();

        builder.HasIndex(x => new { x.CustomerId, x.CreatedAt }).HasDatabaseName("ix_service_requests_customer_id_created_at");
        builder.HasIndex(x => new { x.ProviderLocationId, x.Status, x.CreatedAt }).HasDatabaseName("ix_service_requests_provider_location_id_status_created_at");

        builder.HasOne(x => x.Customer)
            .WithMany()
            .HasForeignKey(x => x.CustomerId)
            .HasConstraintName("fk_service_requests_users_customer_id")
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.GeneralProvider)
            .WithMany(gp => gp.ServiceRequests)
            .HasForeignKey(x => x.GeneralProviderId)
            .HasConstraintName("fk_service_requests_general_providers_general_provider_id")
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.ProviderLocation)
            .WithMany()
            .HasForeignKey(x => new { x.ProviderLocationId, x.GeneralProviderId })
            .HasPrincipalKey(pl => new { pl.Id, pl.ProviderId })
            .HasConstraintName("fk_service_requests_provider_location_owner")
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Service)
            .WithMany(s => s.ServiceRequests)
            .HasForeignKey(x => x.ServiceId)
            .HasConstraintName("fk_service_requests_services_service_id")
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.CancelledByUser)
            .WithMany()
            .HasForeignKey(x => x.CancelledByUserId)
            .HasConstraintName("fk_service_requests_users_cancelled_by_user_id")
            .OnDelete(DeleteBehavior.SetNull);
    }
}
