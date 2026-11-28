using Backend.Domain.Common;
using Backend.Domain.Identity;
using Backend.Domain.Providers;

namespace Backend.Domain.Marketplace;

public class ServiceRequest : AuditableEntity
{
    public Guid CustomerId { get; set; }
    public Guid GeneralProviderId { get; set; }
    public Guid ProviderLocationId { get; set; }
    public Guid ServiceId { get; set; }
    public ServiceRequestStatus Status { get; set; } = ServiceRequestStatus.PENDING;
    public string Description { get; set; } = string.Empty;
    public string ServiceAddress { get; set; } = string.Empty;
    public DateTimeOffset? PreferredDate { get; set; }
    public decimal? AgreedPrice { get; set; }
    public string? RejectionReason { get; set; }
    public string? CancellationReason { get; set; }
    public DateTimeOffset? CancelledAt { get; set; }
    public Guid? CancelledByUserId { get; set; }
    public DateTimeOffset? CompletedAt { get; set; }
    public uint RowVersion { get; set; }

    public User Customer { get; set; } = null!;
    public GeneralProvider GeneralProvider { get; set; } = null!;
    public ProviderLocation ProviderLocation { get; set; } = null!;
    public Service Service { get; set; } = null!;
    public User? CancelledByUser { get; set; }
    public ICollection<ServiceRequestStatusHistory> StatusHistory { get; set; } = new List<ServiceRequestStatusHistory>();
}
