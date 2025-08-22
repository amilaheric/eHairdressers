using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Services.Database
{
    public class OrderItems
    {
        [Key]
        public int OrderItemId { get; set; }
        public int OrderId { get; set; }
        public int ProductId { get; set; }
        public int Quantity { get; set; }
        public double Price { get; set; }
        public virtual Orders Order { get; set; }
        public virtual Products Product { get; set; }

    }
}