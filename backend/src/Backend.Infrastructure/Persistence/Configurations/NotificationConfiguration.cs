using Backend.Domain.Communication;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        builder.ToTable("notifications");
        builder.HasKey(x => x.Id).HasName("pk_notifications");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.UserId).HasColumnName("user_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.Type).HasColumnName("type").HasColumnType("varchar(50)").HasMaxLength(50).IsRequired();
        builder.Property(x => x.Title).HasColumnName("title").HasColumnType("varchar(150)").HasMaxLength(150).IsRequired();
        builder.Property(x => x.Body).HasColumnName("body").HasColumnType("text").IsRequired();
        builder.Property(x => x.ReferenceType).HasColumnName("reference_type").HasColumnType("varchar(40)").HasMaxLength(40);
        builder.Property(x => x.ReferenceId).HasColumnName("reference_id").HasColumnType("uuid");
        builder.Property(x => x.IsRead).HasColumnName("is_read").HasColumnType("boolean").HasDefaultValue(false).IsRequired();
        builder.Property(x => x.ReadAt).HasColumnName("read_at").HasColumnType("timestamptz");
        builder.Property(x => x.CreatedAt).HasColumnName("created_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => new { x.UserId, x.IsRead, x.CreatedAt }).HasDatabaseName("ix_notifications_user_id_is_read_created_at");

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .HasConstraintName("fk_notifications_users_user_id")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
