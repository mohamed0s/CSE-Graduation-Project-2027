using Backend.Domain.Healthcare;
using Backend.Domain.Providers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class HealthcareProviderConfiguration : IEntityTypeConfiguration<HealthcareProvider>
{
    public void Configure(EntityTypeBuilder<HealthcareProvider> builder)
    {
        builder.ToTable("healthcare_providers", t =>
        {
            t.HasCheckConstraint("ck_healthcare_providers_type", "provider_type = 'HEALTHCARE'");
            t.HasCheckConstraint("ck_healthcare_providers_average_rating", "average_rating >= 0 AND average_rating <= 5");
        });

        builder.HasKey(x => x.ProviderId).HasName("pk_healthcare_providers");

        builder.Property(x => x.ProviderId).HasColumnName("provider_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ProviderType).HasColumnName("provider_type").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>().HasDefaultValue(ProviderType.HEALTHCARE).IsRequired();
        builder.Property(x => x.SpecialtyId).HasColumnName("specialty_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.FullName).HasColumnName("full_name").HasColumnType("varchar(150)").HasMaxLength(150).IsRequired();
        builder.Property(x => x.Title).HasColumnName("title").HasColumnType("varchar(100)").HasMaxLength(100);
        builder.Property(x => x.Bio).HasColumnName("bio").HasColumnType("text");
        builder.Property(x => x.AverageRating).HasColumnName("average_rating").HasColumnType("numeric(3,2)").HasDefaultValue(0.00m).IsRequired();
        builder.Property(x => x.TotalReviews).HasColumnName("total_reviews").HasColumnType("integer").HasDefaultValue(0).IsRequired();
        builder.Property(x => x.IsActive).HasColumnName("is_active").HasColumnType("boolean").HasDefaultValue(true).IsRequired();
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => new { x.SpecialtyId, x.IsActive }).HasDatabaseName("ix_healthcare_providers_specialty_id_is_active");

        builder.HasOne(x => x.Provider)
            .WithOne()
            .HasForeignKey<HealthcareProvider>(x => new { x.ProviderId, x.ProviderType })
            .HasPrincipalKey<Provider>(p => new { p.Id, p.ProviderType })
            .HasConstraintName("fk_healthcare_providers_provider_type")
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Specialty)
            .WithMany(s => s.HealthcareProviders)
            .HasForeignKey(x => x.SpecialtyId)
            .HasConstraintName("fk_healthcare_providers_medical_specialties_specialty_id")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
