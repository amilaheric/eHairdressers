using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model
{
    public class Orders
    {
        public int OrderId { get; set; }
        public string OrderNumber { get; set; } = null!;
        public int CustomerId { get; set; }
        public DateTime OrderDate { get; set; }
        public bool Status { get; set; }
        public string PaymentId { get; set; }
        public bool? Canceled { get; set; }
    }
}
