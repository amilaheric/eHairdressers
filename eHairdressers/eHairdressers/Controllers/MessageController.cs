using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    public class MessageController : BaseCRUDController<Message, BaseSearchObject, MessageInsertRequest, object>
    {
        private readonly IMessageService _messageService;

        public MessageController(ILogger<BaseController<Message, BaseSearchObject>> logger, IMessageService service) : base(logger, service)
        {
            _messageService = service;
        }

        [HttpGet("{chatRoomId}")]
        public async Task<List<Message>> GetMessagesByChatRoomId(int chatRoomId)
        {
            return await _messageService.GetMessagesByChatRoomId(chatRoomId);
        }

        [HttpGet("UnreadCount/{userId}")]
        public async Task<ActionResult<int>> GetUnreadMessageCount(int userId)
        {
            var count = await _messageService.GetUnreadMessageCount(userId);
            return Ok(count);
        }

        [HttpPut("Read/{chatRoomId}/{userId}")]
        public async Task<ActionResult> MarkMessagesAsRead(int chatRoomId, int userId)
        {
            await _messageService.MarkMessagesAsRead(chatRoomId, userId);
            return Ok();
        }

        [HttpPost]
        public override async Task<Message> Insert([FromBody] MessageInsertRequest insert)
        {
            return await base.Insert(insert);
        }
    }
}
