using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.Database
{
    public class Appointment
    {
        [Key]
        public int AppointmentId { get; set; }
        public int EmployeeId { get; set; }
        public int UserId { get; set; }
        public int ServiceId { get; set; }
        [Column(TypeName = "Date")]
        public DateTime AppointmentDate { get; set; }
        [Column(TypeName = "Time")]
        public TimeSpan AppointmentTime { get; set; }
        public bool Approved { get; set; }
        public string Comment { get; set; }

        [ForeignKey("ServiceId")]
        public virtual Service Service { get; set; } = null!;
        [ForeignKey("UserId")]
        public virtual User User { get; set; } = null!;
        [ForeignKey("EmployeeId")]
        public virtual Employees Employee { get; set; } = null!;


    }
}
