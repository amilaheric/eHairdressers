using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.Database
{
    public class Products
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public double Price { get; set; }
        public string Code { get; set; }
        public int CategoryId { get; set; }
        public virtual Category Category { get; set; } = null!; 
        public int BrandId { get; set; }
        public int Amount { get; set; }
        public virtual Brand Brand { get; set; } = null!;
        public byte[]? Image { get; set; }
        public byte[]? ImageThumb { get; set; }
        public string? StateMachine { get; set; }
        public string? PaymentId { get; set; } = null!;

        public virtual ICollection<CartItems> CartItems { get; } = new List<CartItems>();
        public virtual ICollection<OrderItems> OrderItems { get; } = new List<OrderItems>();


    }
}
