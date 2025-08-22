using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Model.Requests
{
    public class ProductSalesReportRequest
    {
        [Required]
        public DateTime StartDate { get; set; }
        
        [Required]
        public DateTime EndDate { get; set; }
        
        [Required]
        [RegularExpression("^(sales|revenue|frequency)$", ErrorMessage = "ReportType must be 'sales', 'revenue', or 'frequency'")]
        public string ReportType { get; set; } = string.Empty;
    }
}
