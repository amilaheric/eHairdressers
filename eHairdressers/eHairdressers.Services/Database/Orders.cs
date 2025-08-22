using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.Database
{
    public class Orders
    {
        [Key]
        public int OrderId { get; set; }
        public int UserId { get; set; }
        public string OrderNumber { get; set; } = null!;
        public double TotalPrice { get; set; }
        public DateTime OrderDate { get; set; }
        public bool Status { get; set; }
        public virtual User User { get; set; } = null!;
        public virtual ICollection<OrderItems> OrderItems { get; set; } = new List<OrderItems>();
    }

}
