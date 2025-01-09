namespace eHairdressers.Services.Database
{
    public class CartItems
    {
        public int CartItemsId { get; set; }

        public int CartId { get; set; }

        public int ProductId { get; set; }

        public int Amount { get; set; }

        public int Price { get; set; }

        public int? Discount { get; set; }

        public virtual Cart Cart { get; set; } = null!;

        public virtual Products Product { get; set; } = null!;
    }
}