using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Model.Requests
{
    public class MessageInsertRequest
    {
        [Required]
        public int ChatRoomId { get; set; }
        
        [Required]
        public int SenderId { get; set; }
        
        [Required]
        [StringLength(1000, ErrorMessage = "Message content cannot exceed 1000 characters")]
        public string Content { get; set; } = string.Empty;
        
        public string? SenderType { get; set; }
    }
}
