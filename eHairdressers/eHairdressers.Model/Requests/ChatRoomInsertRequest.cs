using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Model.Requests
{
    public class ChatRoomInsertRequest
    {
        [Required]
        [StringLength(100, ErrorMessage = "Name cannot exceed 100 characters")]
        public string Name { get; set; } = string.Empty;
        
        [Required]
        public List<int> UserIds { get; set; } = new List<int>();
    }
}
