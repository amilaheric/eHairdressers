using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model.SearchObjects
{
    public class UserSearchObject:BaseSearchObject
    {
        public bool? IsUlogeIncluded { get; set; }
        public string? Name { get; set; }
    }
}
