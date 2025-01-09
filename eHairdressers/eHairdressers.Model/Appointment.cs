using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model
{
    public class Appointment
    {
        public int AppointmentId { get; set; }
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public int UserId { get; set; }
        public string Username { get; set; }
        public int ServiceId { get; set; }
        public string ServiceName { get; set; }
        public string AppointmentDate { get; set; }
        public string AppointmentTime { get; set; }
        public bool Approved { get; set; }
        public string Comment { get; set; }

    
    }
}
