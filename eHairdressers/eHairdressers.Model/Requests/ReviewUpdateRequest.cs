using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Model.Requests
{
    public class ReviewUpdateRequest
    {
        [StringLength(500, ErrorMessage = "Comment cannot exceed 500 characters")]
        public string? Comment { get; set; }
        
        [Range(1, 5, ErrorMessage = "Rate must be between 1 and 5")]
        public int? Rate { get; set; }
    }
}
