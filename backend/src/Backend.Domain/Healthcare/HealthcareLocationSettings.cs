using Backend.Domain.Providers;

namespace Backend.Domain.Healthcare;

public class HealthcareLocationSettings
{
    public Guid Id { get; set; }
    public Guid ProviderLocationId { get; set; }
    public ProviderType ProviderType { get; set; } = ProviderType.HEALTHCARE;
    public decimal ConsultationFee { get; set; }
    public int SlotDurationMinutes { get; set; } = 30;
    public bool RequiresApproval { get; set; } = true;
    public string Timezone { get; set; } = "Africa/Cairo";
    public DateTimeOffset UpdatedAt { get; set; }

    public ProviderLocation ProviderLocation { get; set; } = null!;
}
