using System;

namespace eHairdressers.Model.Messages
{
    public class AppointmentCreatedMessage
    {
        public int AppointmentId { get; set; }
        public int UserId { get; set; }
        public string UserName { get; set; }
        public string UserEmail { get; set; }
        public int EmployeeId { get; set; }
        public string EmployeeName { get; set; }
        public int ServiceId { get; set; }
        public string ServiceName { get; set; }
        public DateTime AppointmentDate { get; set; }
        public TimeSpan AppointmentTime { get; set; }
        public bool? Approved { get; set; }
        public string Comment { get; set; }

    }
}

