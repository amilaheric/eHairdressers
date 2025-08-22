using Microsoft.AspNetCore.SignalR;
using eHairdressers.Hubs;

namespace eHairdressers.Services
{
    public class NotificationService : INotificationService
    {
        private readonly IHubContext<ChatHub> _hubContext;

        public NotificationService(IHubContext<ChatHub> hubContext)
        {
            _hubContext = hubContext;
        }

        public async Task NotifyUser(int userId, string message, string type)
        {
            await _hubContext.Clients.User(userId.ToString()).SendAsync("ReceiveNotification", message, type);
        }

        public async Task NotifyChatRoom(int chatRoomId, string message, string type, int? excludeUserId = null)
        {
            if (excludeUserId.HasValue)
            {
                await _hubContext.Clients.Group($"ChatRoom_{chatRoomId}").SendAsync("ReceiveNotification", message, type, excludeUserId.Value);
            }
            else
            {
                await _hubContext.Clients.Group($"ChatRoom_{chatRoomId}").SendAsync("ReceiveNotification", message, type);
            }
        }

        public async Task NotifyAllUsers(string message, string type)
        {
            await _hubContext.Clients.All.SendAsync("ReceiveNotification", message, type);
        }

        public async Task UpdateUserUnreadCount(int userId, int count)
        {
            await _hubContext.Clients.User(userId.ToString()).SendAsync("UpdateUnreadCount", count);
        }
    }
}
