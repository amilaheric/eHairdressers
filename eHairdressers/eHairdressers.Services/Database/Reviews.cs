using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Services.Database
{
    public class Reviews
    {
        [Key]
        public int ReviewId { get; set; }
        public int AppointmentId { get; set; }
        public int? UserId { get; set; }
        public string? Comment { get; set; }
        public int? Rate { get; set; }
        public virtual User? User { get; set; } = null!;
        public virtual Appointment Appointment { get; set; } = null!;
    }
}