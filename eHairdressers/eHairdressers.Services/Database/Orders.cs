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

        public string OrderNumber { get; set; } = null!;

        public int CustomerId { get; set; }

        public DateTime OrderDate { get; set; }

        public bool Status { get; set; }

        public bool? Canceled { get; set; }
        public string PaymentId { get; set; } = null!;

        public virtual ICollection<Cart> Cart { get; } = new List<Cart>();

        public virtual Customers Customer { get; set; } = null!;

        public virtual ICollection<OrderItems> OrderItems { get; } = new List<OrderItems>();
    }

}
