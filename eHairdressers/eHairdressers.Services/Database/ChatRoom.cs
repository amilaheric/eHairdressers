using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Services.Database
{
    public class ChatRoom
    {
        [Key]
        public int ChatRoomId { get; set; }
        public string Name { get; set; } = string.Empty;
        public DateTime CreatedDate { get; set; }
        public bool IsActive { get; set; } = true;
        
        // Navigation properties
        public virtual ICollection<Message> Messages { get; set; } = new List<Message>();
        public virtual ICollection<ChatRoomUser> ChatRoomUsers { get; set; } = new List<ChatRoomUser>();
    }
}
