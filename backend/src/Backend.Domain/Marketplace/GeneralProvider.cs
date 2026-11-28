using Backend.Domain.Providers;

namespace Backend.Domain.Marketplace;

/// <summary>
/// Specialized General Services provider profile (1-to-1 with Provider where ProviderType == GENERAL).
/// Offers exactly ONE Service.
/// </summary>
public class GeneralProvider
{
    public Guid ProviderId { get; set; }
    public ProviderType ProviderType { get; set; } = ProviderType.GENERAL;
    public Guid ServiceId { get; set; }
    public string DisplayName { get; set; } = string.Empty;
    public string? Bio { get; set; }
    public short? YearsExperience { get; set; }
    public decimal AverageRating { get; set; }
    public int TotalReviews { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }

    public Provider Provider { get; set; } = null!;
    public Service Service { get; set; } = null!;
    public ICollection<ServiceRequest> ServiceRequests { get; set; } = new List<ServiceRequest>();
}
