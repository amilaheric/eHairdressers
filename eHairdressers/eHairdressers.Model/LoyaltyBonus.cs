namespace eHairdressers.Model
{
    public class LoyaltyBonus
    {
        public int BonusId { get; set; }
        public int UserId { get; set; }
        public string BonusType { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public decimal Value { get; set; }
        public int PointsRequired { get; set; }
        public DateTime ExpiryDate { get; set; }
        public bool IsRedeemed { get; set; }
        public DateTime? RedeemedDate { get; set; }
        public string Status { get; set; } = string.Empty; 
    }
}
