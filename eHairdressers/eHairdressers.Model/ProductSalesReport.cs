namespace eHairdressers.Model
{
    public class ProductSalesReport
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; } = string.Empty;
        public string ProductCode { get; set; } = string.Empty;
        public int TotalQuantitySold { get; set; }
        public decimal TotalRevenue { get; set; }
        public int SalesFrequency { get; set; }
        public decimal AveragePrice { get; set; }
        public DateTime ReportStartDate { get; set; }
        public DateTime ReportEndDate { get; set; }
        public string ReportType { get; set; } = string.Empty;
        public List<DailySalesData> DailySales { get; set; } = new List<DailySalesData>();
    }

    public class DailySalesData
    {
        public DateTime Date { get; set; }
        public int QuantitySold { get; set; }
        public decimal Revenue { get; set; }
        public int SalesCount { get; set; }
    }
}
