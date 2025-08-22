using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Model.Requests
{
    public class CalculatePointsRequest
    {
        [Required]
        public int UserId { get; set; }
        
        [Required]
        public decimal Amount { get; set; }
        
        public string? ServiceType { get; set; }
        
        public bool IsFirstTime { get; set; } = false;
        
        public bool IsWeekend { get; set; } = false;
    }
}
