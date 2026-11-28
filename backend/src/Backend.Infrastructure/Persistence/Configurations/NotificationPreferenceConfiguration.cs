using Backend.Domain.Communication;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Backend.Infrastructure.Persistence.Configurations;

public class NotificationPreferenceConfiguration : IEntityTypeConfiguration<NotificationPreference>
{
    public void Configure(EntityTypeBuilder<NotificationPreference> builder)
    {
        builder.ToTable("notification_preferences");
        builder.HasKey(x => x.Id).HasName("pk_notification_preferences");

        builder.Property(x => x.Id).HasColumnName("id").HasColumnType("uuid").HasDefaultValueSql("gen_random_uuid()");
        builder.Property(x => x.UserId).HasColumnName("user_id").HasColumnType("uuid").IsRequired();
        builder.Property(x => x.InAppEnabled).HasColumnName("in_app_enabled").HasColumnType("boolean").HasDefaultValue(true).IsRequired();
        builder.Property(x => x.PushEnabled).HasColumnName("push_enabled").HasColumnType("boolean").HasDefaultValue(true).IsRequired();
        builder.Property(x => x.EmailEnabled).HasColumnName("email_enabled").HasColumnType("boolean").HasDefaultValue(true).IsRequired();
        builder.Property(x => x.UpdatedAt).HasColumnName("updated_at").HasColumnType("timestamptz").HasDefaultValueSql("now()").IsRequired();

        builder.HasIndex(x => x.UserId).IsUnique().HasDatabaseName("uq_notification_preferences_user_id");

        builder.HasOne(x => x.User)
            .WithOne()
            .HasForeignKey<NotificationPreference>(x => x.UserId)
            .HasConstraintName("fk_notification_preferences_users_user_id")
            .OnDelete(DeleteBehavior.Cascade);
    }
}
