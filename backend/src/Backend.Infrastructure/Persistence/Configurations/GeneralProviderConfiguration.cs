using Backend.Domain.Marketplace;
using Backend.Domain.Providers;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class GeneralProviderConfiguration : IEntityTypeConfiguration<GeneralProvider>
{
    public void Configure(EntityTypeBuilder<GeneralProvider> builder)
    {
        builder.ToTable("general_providers", t =>
        {
            t.HasCheckConstraint("ck_general_providers_type", "provider_type = 'GENERAL'");
            t.HasCheckConstraint("ck_general_providers_years_experience", "years_experience IS NULL OR years_experience >= 0");
            t.HasCheckConstraint("ck_general_providers_average_rating", "average_rating >= 0 AND average_rating <= 5");
        });

        builder.HasKey(x => x.ProviderId).HasName("pk_general_providers");

        builder.Property(x => x.ProviderId).HasColumnName("provider_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.ProviderType).HasColumnName("provider_type").HasColumnType("varchar(30)").HasMaxLength(30).HasConversion<string>().HasDefaultValue(ProviderType.GENERAL).IsRequired();
        builder.Property(x => x.ServiceId).HasColumnName("service_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.DisplayName).HasColumnName("display_name").HasColumnType("varchar(150)").HasMaxLength(150).IsRequired();
        builder.Property(x => x.Bio).HasColumnName("bio").HasColumnType("text");
        builder.Property(x => x.YearsExperience).HasColumnName("years_experience").HasColumnType("smallint");
        builder.Property(x => x.AverageRating).HasColumnName("average_rating").HasColumnType("numeric(3,2)").HasDefaultValue(0.00m).IsRequired();
        builder.Property(x => x.TotalReviews).HasColumnName("total_reviews").HasColumnType("integer").HasDefaultValue(0).IsRequired();
        builder.Property(x => x.IsActive).HasColumnName("is_active").HasColumnType("boolean").HasDefaultValue(true).IsRequired();
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => new { x.ServiceId, x.IsActive }).HasDatabaseName("ix_general_providers_service_id_is_active");

        builder.HasOne(x => x.Provider)
            .WithOne()
            .HasForeignKey<GeneralProvider>(x => new { x.ProviderId, x.ProviderType })
            .HasPrincipalKey<Provider>(p => new { p.Id, p.ProviderType })
            .HasConstraintName("fk_general_providers_provider_type")
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Service)
            .WithMany(s => s.GeneralProviders)
            .HasForeignKey(x => x.ServiceId)
            .HasConstraintName("fk_general_providers_services_service_id")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
