using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Model
{
    public class ChatRoom
    {
        public int ChatRoomId { get; set; }
        public string Name { get; set; } = string.Empty;
        public DateTime CreatedDate { get; set; }
        public bool IsActive { get; set; }
        public List<User> Users { get; set; } = new List<User>();
        public List<Message> Messages { get; set; } = new List<Message>();
    }
}
