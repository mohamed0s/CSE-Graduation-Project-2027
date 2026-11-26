using Backend.Domain.Common;
using Backend.Domain.Food;
using Backend.Domain.Healthcare;
using Backend.Domain.Identity;
using Backend.Domain.Marketplace;

namespace Backend.Domain.Reviews;

public class Review : AuditableEntity
{
    public Guid CustomerId { get; set; }
    public ReviewTargetDomain TargetDomain { get; set; }
    public Guid? ServiceRequestId { get; set; }
    public Guid? FoodOrderId { get; set; }
    public Guid? HealthcareAppointmentId { get; set; }
    public short Rating { get; set; }
    public string? Comment { get; set; }

    public User Customer { get; set; } = null!;
    public ServiceRequest? ServiceRequest { get; set; }
    public FoodOrder? FoodOrder { get; set; }
    public HealthcareAppointment? HealthcareAppointment { get; set; }
}
