using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model.Requests
{
    public class UserInsertRequest
    {

        public string Name { get; set; } 

        public string Surname { get; set; }

        public string? Email { get; set; }

        public string? Phone { get; set; }
        public string? BirthDate { get; set; }
        public string? Address { get; set; }
        public string CitizenshipNumber { get; set; }
        public byte[]? Image { get; set; }
        public byte[]? ImageThumb { get; set; }
        public string Username { get; set; }
        public bool? Status { get; set; }
        public string Password { get; set; }
        public string PasswordConfirm { get; set; }
    }
}
