using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.Database
{
    public class Availability
    {
        public int AvailabilityId { get; set; }
        public int UserId { get; set; }
        public DateTime AppointmentDate { get; set; }

        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set;}

        public virtual User User { get; set; } = null!;


    }
}
