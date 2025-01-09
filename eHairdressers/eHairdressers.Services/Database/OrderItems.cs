namespace eHairdressers.Services.Database
{
    public class OrderItems
    {
        public int OrderItemsId { get; set; }

        public int OrderId { get; set; }

        public int ProductId { get; set; }

        public int Quantity { get; set; }

        public virtual Orders Order { get; set; } = null!;

        public virtual Products Product { get; set; } = null!;
    }
}