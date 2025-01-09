using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model.Requests
{
    public class UserUpdateRequest
    {
        public string Name { get; set; } = null!;

        public string Surname { get; set; } = null!;

        public string? Email { get; set; }

        public string? Phone { get; set; }

        public bool? Status { get; set; }
    }
}
