using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model
{
    public class Service
    {
        public int ServiceId { get; set; }
        public string ServiceName { get; set; }

        public string Description { get; set; }

        public string Duration { get; set; }

    }
}
