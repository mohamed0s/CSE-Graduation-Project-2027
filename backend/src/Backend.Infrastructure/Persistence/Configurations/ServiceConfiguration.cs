using Backend.Domain.Marketplace;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class ServiceConfiguration : IEntityTypeConfiguration<Service>
{
    public void Configure(EntityTypeBuilder<Service> builder)
    {
        builder.ToTable("services", t =>
        {
            t.HasCheckConstraint("ck_services_base_price", "base_price IS NULL OR base_price >= 0");
        });

        builder.HasKey(x => x.Id).HasName("pk_services");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.CategoryId).HasColumnName("category_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.Name).HasColumnName("name").HasColumnType("varchar(150)").HasMaxLength(150).IsRequired();
        builder.Property(x => x.Description).HasColumnName("description").HasColumnType("text");
        builder.Property(x => x.BasePrice).HasColumnName("base_price").HasColumnType("numeric(12,2)");
        builder.Property(x => x.IsActive).HasColumnName("is_active").HasColumnType("boolean").HasDefaultValue(true).IsRequired();
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => x.CategoryId).HasDatabaseName("ix_services_category_id");

        builder.HasOne(x => x.Category)
            .WithMany(c => c.Services)
            .HasForeignKey(x => x.CategoryId)
            .HasConstraintName("fk_services_service_categories_category_id")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
