using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.Database
{
    public class Customers
    {
        [Key]
        public int  CustomerId { get; set; }

        public string Name { get; set; }

        public string Surname { get; set; }

        public string? Email { get; set; }

        public string? BirthDate { get; set; }
        public string? Address { get; set; }
        public string CitizenshipNumber { get; set; }
        public string? Phone { get; set; }

        public byte[]? Image { get; set; }
        public byte[]? ImageThumb { get; set; }

    }
}
