using Backend.Domain.Common;

namespace Backend.Domain.Healthcare;

public class MedicalSpecialty : AuditableEntity
{
    public string Name { get; set; } = string.Empty;
    public string Slug { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;

    public ICollection<HealthcareProvider> HealthcareProviders { get; set; } = new List<HealthcareProvider>();
}
