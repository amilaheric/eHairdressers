using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RealTimeChatController : ControllerBase
    {
        private readonly INotificationService _notificationService;
        private readonly IMessageService _messageService;

        public RealTimeChatController(INotificationService notificationService, IMessageService messageService)
        {
            _notificationService = notificationService;
            _messageService = messageService;
        }

        [HttpPost("notify-user")]
        public async Task<IActionResult> NotifyUser([FromBody] NotifyUserRequest request)
        {
            try
            {
                await _notificationService.NotifyUser(request.UserId, request.Message, request.Type);
                return Ok(new { success = true, message = "Notification sent successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost("notify-chatroom")]
        public async Task<IActionResult> NotifyChatRoom([FromBody] NotifyChatRoomRequest request)
        {
            try
            {
                await _notificationService.NotifyChatRoom(request.ChatRoomId, request.Message, request.Type, request.ExcludeUserId);
                return Ok(new { success = true, message = "Chat room notification sent successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost("notify-all")]
        public async Task<IActionResult> NotifyAllUsers([FromBody] NotifyAllRequest request)
        {
            try
            {
                await _notificationService.NotifyAllUsers(request.Message, request.Type);
                return Ok(new { success = true, message = "Global notification sent successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("unread-count/{userId}")]
        public async Task<IActionResult> GetUnreadCount(int userId)
        {
            try
            {
                var unreadCount = await _messageService.GetUnreadMessageCount(userId);
                return Ok(new { success = true, unreadCount });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost("mark-read")]
        public async Task<IActionResult> MarkMessagesAsRead([FromBody] MarkAsReadRequest request)
        {
            try
            {
                await _messageService.MarkMessagesAsRead(request.ChatRoomId, request.UserId);
                return Ok(new { success = true, message = "Messages marked as read successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }

    public class NotifyUserRequest
    {
        public int UserId { get; set; }
        public string Message { get; set; } = string.Empty;
        public string Type { get; set; } = "info";
    }

    public class NotifyChatRoomRequest
    {
        public int ChatRoomId { get; set; }
        public string Message { get; set; } = string.Empty;
        public string Type { get; set; } = "info";
        public int? ExcludeUserId { get; set; }
    }

    public class NotifyAllRequest
    {
        public string Message { get; set; } = string.Empty;
        public string Type { get; set; } = "info";
    }

    public class MarkAsReadRequest
    {
        public int ChatRoomId { get; set; }
        public int UserId { get; set; }
    }
}
