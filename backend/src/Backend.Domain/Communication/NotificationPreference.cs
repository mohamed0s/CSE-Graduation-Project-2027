using Backend.Domain.Identity;

namespace Backend.Domain.Communication;

public class NotificationPreference
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public bool InAppEnabled { get; set; } = true;
    public bool PushEnabled { get; set; } = true;
    public bool EmailEnabled { get; set; } = true;
    public DateTimeOffset UpdatedAt { get; set; }

    public User User { get; set; } = null!;
}
