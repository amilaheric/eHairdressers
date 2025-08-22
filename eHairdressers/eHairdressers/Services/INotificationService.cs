using eHairdressers.Model;

namespace eHairdressers.Services
{
    public interface INotificationService
    {
        Task NotifyUser(int userId, string message, string type);
        Task NotifyChatRoom(int chatRoomId, string message, string type, int? excludeUserId = null);
        Task NotifyAllUsers(string message, string type);
        Task UpdateUserUnreadCount(int userId, int count);
    }
}
