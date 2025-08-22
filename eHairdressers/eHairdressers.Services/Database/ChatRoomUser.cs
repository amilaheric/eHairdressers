using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Services.Database
{
    public class ChatRoomUser
    {
        [Key]
        public int ChatRoomUserId { get; set; }
        public int ChatRoomId { get; set; }
        public int UserId { get; set; }
        public DateTime JoinedDate { get; set; }
        public bool IsActive { get; set; } = true;
        
        // Navigation properties
        public virtual ChatRoom ChatRoom { get; set; } = null!;
        public virtual User User { get; set; } = null!;
    }
}
