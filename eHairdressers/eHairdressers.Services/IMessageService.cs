using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;

namespace eHairdressers.Services
{
    public interface IMessageService : ICRUDService<Message, BaseSearchObject, MessageInsertRequest, object>
    {
        Task<List<Message>> GetMessagesByChatRoomId(int chatRoomId);
        Task<int> GetUnreadMessageCount(int userId);
        Task MarkMessagesAsRead(int chatRoomId, int userId);
    }
}
