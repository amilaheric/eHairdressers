using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;

namespace eHairdressers.Services
{
    public interface IChatRoomService : ICRUDService<ChatRoom, BaseSearchObject, ChatRoomInsertRequest, object>
    {
        Task<List<ChatRoom>> GetChatRoomsByUserId(int userId);
        Task<ChatRoom> GetChatRoomWithUsers(int chatRoomId);
        Task<int> DeactivateInactiveChatRooms(int retentionDays);
        Task<(bool Allowed, string? Error)> CanUserJoinAsync(int chatRoomId, int userId);
    }
}
