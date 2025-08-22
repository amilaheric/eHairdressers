using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Model.Requests
{
    public class SalonOperationsReportRequest
    {
        [Required]
        public DateTime StartDate { get; set; }
        
        [Required]
        public DateTime EndDate { get; set; }
        
        [Required]
        [RegularExpression("^(daily|weekly|monthly|yearly)$", ErrorMessage = "ReportPeriod must be 'daily', 'weekly', 'monthly', or 'yearly'")]
        public string ReportPeriod { get; set; } = "monthly";
    }
}
