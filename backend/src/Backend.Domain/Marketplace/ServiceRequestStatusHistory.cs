using Backend.Domain.Identity;

namespace Backend.Domain.Marketplace;

public class ServiceRequestStatusHistory
{
    public Guid Id { get; set; }
    public Guid ServiceRequestId { get; set; }
    public ServiceRequestStatus? FromStatus { get; set; }
    public ServiceRequestStatus ToStatus { get; set; }
    public Guid ChangedByUserId { get; set; }
    public string? Note { get; set; }
    public DateTimeOffset CreatedAt { get; set; }

    public ServiceRequest ServiceRequest { get; set; } = null!;
    public User ChangedByUser { get; set; } = null!;
}
