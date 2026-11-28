using Backend.Domain.Common;
using Backend.Domain.Identity;
using Backend.Domain.Providers;

namespace Backend.Domain.Healthcare;

public class HealthcareAppointment : AuditableEntity
{
    public Guid CustomerId { get; set; }
    public Guid HealthcareProviderId { get; set; }
    public Guid ProviderLocationId { get; set; }
    public DateTimeOffset StartAt { get; set; }
    public DateTimeOffset EndAt { get; set; }
    public int DurationMinutes { get; set; }
    public decimal ConsultationFeeSnapshot { get; set; }
    public AppointmentStatus Status { get; set; } = AppointmentStatus.PENDING;
    public string? PatientNotes { get; set; }
    public string? RejectionReason { get; set; }
    public string? CancellationReason { get; set; }
    public DateTimeOffset? CancelledAt { get; set; }
    public Guid? CancelledByUserId { get; set; }
    public Guid? RescheduledFromAppointmentId { get; set; }
    public uint RowVersion { get; set; }

    public User Customer { get; set; } = null!;
    public HealthcareProvider HealthcareProvider { get; set; } = null!;
    public ProviderLocation ProviderLocation { get; set; } = null!;
    public User? CancelledByUser { get; set; }
    public HealthcareAppointment? RescheduledFromAppointment { get; set; }
    public ICollection<AppointmentStatusHistory> StatusHistory { get; set; } = new List<AppointmentStatusHistory>();
}
