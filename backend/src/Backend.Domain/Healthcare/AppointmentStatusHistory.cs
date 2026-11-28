using Backend.Domain.Identity;

namespace Backend.Domain.Healthcare;

public class AppointmentStatusHistory
{
    public Guid Id { get; set; }
    public Guid AppointmentId { get; set; }
    public AppointmentStatus? FromStatus { get; set; }
    public AppointmentStatus ToStatus { get; set; }
    public Guid ChangedByUserId { get; set; }
    public string? Note { get; set; }
    public DateTimeOffset CreatedAt { get; set; }

    public HealthcareAppointment Appointment { get; set; } = null!;
    public User ChangedByUser { get; set; } = null!;
}
