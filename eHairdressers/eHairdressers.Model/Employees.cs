using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model
{
    public class Employees
    {
        public int EmployeeId { get; set; }
        public int UserId { get; set; }
        public string Name { get; set; }
        public string Surname { get; set; }
        public DateTime HireDate { get; set; }
        public string? BirthDate { get; set; }
        public string? Address { get; set; }
        public string CitizenshipNumber { get; set; }
        public string? Phone { get; set; }
        public int Salary { get; set; }
    }
}
