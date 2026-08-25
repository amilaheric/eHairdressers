using eHairdressers.Hubs;
using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;

namespace eHairdressers.Controllers
{
    public class ChatRoomController : BaseCRUDController<ChatRoom, BaseSearchObject, ChatRoomInsertRequest, object>
    {
        private readonly IChatRoomService _chatRoomService;
        private readonly IHubContext<ChatHub> _hubContext;

        public ChatRoomController(ILogger<BaseController<ChatRoom, BaseSearchObject>> logger, IChatRoomService service, IHubContext<ChatHub> hubContext) : base(logger, service)
        {
            _chatRoomService = service;
            _hubContext = hubContext;
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
            var result = await base.Insert(insert);

            // Push to everyone connected so chat lists on other devices update
            // immediately instead of requiring a manual refresh.
            await _hubContext.Clients.All.SendAsync("ChatRoomCreated", result);

            return result;
        }
    }
}
