namespace eHairdressers.Model
{
    public class Products
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public double Price { get; set; }
        public string Code { get; set; }
        public string PaymentId { get; set; }
        public int CategoryId { get; set; }
        public int BrandId { get; set; }
        public byte[] Image { get; set; }
        public string StateMachine { get; set; }
    }
}