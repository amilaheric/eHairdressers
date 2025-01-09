using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.Database
{
    public class Service
    {
        [Key]
        public int ServiceId { get; set; }
        public string ServiceName { get; set; }

        public string Description { get; set; }

        public string Duration { get; set; }

        public virtual ICollection<Appointment> AppointmentsL { get; } = new List<Appointment>();

    }
}
