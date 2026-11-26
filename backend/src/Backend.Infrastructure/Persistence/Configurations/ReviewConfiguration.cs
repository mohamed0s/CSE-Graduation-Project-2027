using Backend.Domain.Reviews;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class ReviewConfiguration : IEntityTypeConfiguration<Review>
{
    public void Configure(EntityTypeBuilder<Review> builder)
    {
        builder.ToTable("reviews", t =>
        {
            t.HasCheckConstraint(
                "ck_reviews_target_domain",
                "target_domain IN ('GENERAL_SERVICE','FOOD_ORDER','HEALTHCARE')");
            t.HasCheckConstraint("ck_reviews_rating", "rating >= 1 AND rating <= 5");
            t.HasCheckConstraint(
                "ck_reviews_single_target",
                "(target_domain = 'GENERAL_SERVICE' AND service_request_id IS NOT NULL AND food_order_id IS NULL AND healthcare_appointment_id IS NULL) OR " +
                "(target_domain = 'FOOD_ORDER' AND service_request_id IS NULL AND food_order_id IS NOT NULL AND healthcare_appointment_id IS NULL) OR " +
                "(target_domain = 'HEALTHCARE' AND service_request_id IS NULL AND food_order_id IS NULL AND healthcare_appointment_id IS NOT NULL)");
        });

        builder.HasKey(x => x.Id).HasName("pk_reviews");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.CustomerId).HasColumnName("customer_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.TargetDomain).HasColumnName("target_domain").HasColumnType("varchar(20)").HasMaxLength(20).HasConversion<string>().IsRequired();
        builder.Property(x => x.ServiceRequestId).HasColumnName("service_request_id").HasColumnType("uuid");
        builder.Property(x => x.FoodOrderId).HasColumnName("food_order_id").HasColumnType("uuid");
        builder.Property(x => x.HealthcareAppointmentId).HasColumnName("healthcare_appointment_id").HasColumnType("uuid");
        builder.Property(x => x.Rating).HasColumnName("rating").HasColumnType("smallint").IsRequired();
        builder.Property(x => x.Comment).HasColumnName("comment").HasColumnType("text");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => x.ServiceRequestId).IsUnique().HasDatabaseName("uq_reviews_service_request_id");
        builder.HasIndex(x => x.FoodOrderId).IsUnique().HasDatabaseName("uq_reviews_food_order_id");
        builder.HasIndex(x => x.HealthcareAppointmentId).IsUnique().HasDatabaseName("uq_reviews_healthcare_appointment_id");

        builder.HasOne(x => x.Customer)
            .WithMany()
            .HasForeignKey(x => x.CustomerId)
            .HasConstraintName("fk_reviews_users_customer_id")
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.ServiceRequest)
            .WithOne()
            .HasForeignKey<Review>(x => x.ServiceRequestId)
            .HasConstraintName("fk_reviews_service_requests_service_request_id")
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.FoodOrder)
            .WithOne()
            .HasForeignKey<Review>(x => x.FoodOrderId)
            .HasConstraintName("fk_reviews_food_orders_food_order_id")
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.HealthcareAppointment)
            .WithOne()
            .HasForeignKey<Review>(x => x.HealthcareAppointmentId)
            .HasConstraintName("fk_reviews_healthcare_appointments_healthcare_appointment_id")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
