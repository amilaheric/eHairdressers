using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    public class ChatRoomController : BaseCRUDController<ChatRoom, BaseSearchObject, ChatRoomInsertRequest, object>
    {
        private readonly IChatRoomService _chatRoomService;

        public ChatRoomController(ILogger<BaseController<ChatRoom, BaseSearchObject>> logger, IChatRoomService service) : base(logger, service)
        {
            _chatRoomService = service;
        }

        [HttpGet("{userId}")]
        public async Task<List<ChatRoom>> GetChatRoomsByUserId(int userId)
        {
            return await _chatRoomService.GetChatRoomsByUserId(userId);
        }

        [HttpGet("with-users/{chatRoomId}")]
        public async Task<ChatRoom> GetChatRoomWithUsers(int chatRoomId)
        {
            return await _chatRoomService.GetChatRoomWithUsers(chatRoomId);
        }

        [HttpPost]
        public override async Task<ChatRoom> Insert([FromBody] ChatRoomInsertRequest insert)
        {
            return await base.Insert(insert);
        }
    }
}
