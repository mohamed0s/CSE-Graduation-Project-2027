using Backend.Domain.Providers;

namespace Backend.Domain.Healthcare;

/// <summary>
/// Specialized Healthcare provider profile (1-to-1 with Provider where ProviderType == HEALTHCARE).
/// </summary>
public class HealthcareProvider
{
    public Guid ProviderId { get; set; }
    public ProviderType ProviderType { get; set; } = ProviderType.HEALTHCARE;
    public Guid SpecialtyId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string? Title { get; set; }
    public string? Bio { get; set; }
    public decimal AverageRating { get; set; }
    public int TotalReviews { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTimeOffset CreatedAt { get; set; }
    public DateTimeOffset UpdatedAt { get; set; }

    public Provider Provider { get; set; } = null!;
    public MedicalSpecialty Specialty { get; set; } = null!;
    public ICollection<HealthcareAppointment> Appointments { get; set; } = new List<HealthcareAppointment>();
}
