using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.Database
{
    public class Employees
    {
        [Key]
        public int EmployeeId { get; set; }
        public string Name { get; set; } = null!;
        public string Surname { get; set; } = null!;
        public DateTime HireDate { get; set; }
        public string? BirthDate { get; set; }
        public string? Address { get; set; }
        public string CitizenshipNumber { get; set; }
        public string? Phone { get; set; }
        public int Salary { get; set; }

        public virtual ICollection<Appointment> ListAppointments { get; } = new List<Appointment>();
    }
}
