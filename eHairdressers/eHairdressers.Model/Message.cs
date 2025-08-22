using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Model
{
    public class Message
    {
        public int MessageId { get; set; }
        public int ChatRoomId { get; set; }
        public int SenderId { get; set; }
        public string Content { get; set; } = string.Empty;
        public DateTime SentDate { get; set; }
        public bool IsRead { get; set; }
        public string? SenderType { get; set; }
        public User Sender { get; set; } = null!;
    }
}
