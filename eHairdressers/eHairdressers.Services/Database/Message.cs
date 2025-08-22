using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Services.Database
{
    public class Message
    {
        [Key]
        public int MessageId { get; set; }
        public int ChatRoomId { get; set; }
        public int SenderId { get; set; }
        public string Content { get; set; } = string.Empty;
        public DateTime SentDate { get; set; }
        public bool IsRead { get; set; } = false;
        public string? SenderType { get; set; }
        
        // Navigation properties
        public virtual ChatRoom ChatRoom { get; set; } = null!;
        public virtual User Sender { get; set; } = null!;
    }
}
