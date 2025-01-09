namespace eHairdressers.Services.Database
{
    public class Cart
    {
        public int CartId { get; set; }

        public string AccountNumber { get; set; } = null!;

        public DateTime Date { get; set; }

        public int UserId { get; set; }

        public int TotalWithoutVAT { get; set; }

        public int TotalWithVAT { get; set; }

        public int? OrderId { get; set; }

        public virtual ICollection<CartItems> CartItems { get; } = new List<CartItems>();

        public virtual User User { get; set; } = null!;

        public virtual Orders? Order { get; set; }
    }
}