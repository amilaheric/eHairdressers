using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Model
{
    public class Review
    {
        public int ReviewId { get; set; }
        public int AppointmentId { get; set; }
        public int? UserId { get; set; }
        public string? Comment { get; set; }
        public int? Rate { get; set; }
        public virtual User? User { get; set; }
        public virtual Appointment Appointment { get; set; } = null!;
    }
}
