using Backend.Domain.Common;

namespace Backend.Domain.Marketplace;

public class Service : AuditableEntity
{
    public Guid CategoryId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public decimal? BasePrice { get; set; }
    public bool IsActive { get; set; } = true;

    public ServiceCategory Category { get; set; } = null!;
    public ICollection<GeneralProvider> GeneralProviders { get; set; } = new List<GeneralProvider>();
    public ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
