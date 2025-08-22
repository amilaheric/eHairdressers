namespace eHairdressers.Model
{
    public class UserStatistics
    {
        public int UserId { get; set; }
        public int TotalAppointments { get; set; }
        public int CompletedAppointments { get; set; }
        public int CancelledAppointments { get; set; }
        public int NoShowAppointments { get; set; }
        public int TotalOrders { get; set; }
        public int CompletedOrders { get; set; }
        public int CancelledOrders { get; set; }
        public decimal TotalSpent { get; set; }
        public decimal AverageAppointmentValue { get; set; }
        public decimal AverageOrderValue { get; set; }
        public int LoyaltyPoints { get; set; }
        public string LoyaltyTier { get; set; } = string.Empty;
        public decimal LoyaltyDiscount { get; set; }
        public DateTime FirstAppointment { get; set; }
        public DateTime LastAppointment { get; set; }
        public DateTime FirstOrder { get; set; }
        public DateTime LastOrder { get; set; }
    }
}
