using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model.Requests
{
        public class AppointmentInsertRequest
        {
            public int? EmployeeId { get; set; }
            public int? UserId { get; set; }
            public int? ServiceId { get; set; }
            public string? AppointmentDate { get; set; }
            public string? AppointmentTime { get; set; }
            public string Comment { get; set; }

        }
}
