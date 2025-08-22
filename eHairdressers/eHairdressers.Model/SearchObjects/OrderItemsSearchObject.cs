using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model.SearchObjects
{
    public class OrderItemsSearchObject : BaseSearchObject
    {
        public int? OrderId { get; set; }
        public int? ProductId { get; set; }
    }
}
