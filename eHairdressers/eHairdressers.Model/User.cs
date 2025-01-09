using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model
{
    public class User
    {
        public int UserId { get; set; }
        public string Name { get; set; } 
        public string Surname { get; set; }
        public string? Email { get; set; }
        public string? Phone { get; set; }
        public string Username { get; set; }
        public string? BirthDate { get; set; }
        public string? Address { get; set; }
        public string CitizenshipNumber { get; set; }
        public byte[]? Image { get; set; }
        public byte[]? ImageThumb { get; set; }
        public bool? Status { get; set; }
        public virtual ICollection<UserRole> UserRoles { get; } = new List<UserRole>();
    }
}
