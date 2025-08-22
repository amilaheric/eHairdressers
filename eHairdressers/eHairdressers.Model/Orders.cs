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
        public string OrderNumber { get; set; } 
        public int UserId { get; set; }

        public double TotalWithoutVAT { get; set; }
        public double TotalWithVAT { get; set; }
        public string Status { get; set; }  
        public DateTime OrderDate { get; set; }
        public List<OrderItems> OrderItems { get; set; } 
    }
}
