using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using eHairdressers.Hubs;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class SignalRTestController : ControllerBase
    {
        private readonly IHubContext<ChatHub> _hubContext;

        public SignalRTestController(IHubContext<ChatHub> hubContext)
        {
            _hubContext = hubContext;
        }

        [HttpGet("test")]
        public IActionResult Test()
        {
            return Ok(new { message = "SignalR Test Controller is working!", timestamp = DateTime.UtcNow });
        }

        [HttpPost("broadcast")]
        public async Task<IActionResult> Broadcast([FromBody] BroadcastRequest request)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("TestBroadcast", request.Message);
                return Ok(new { success = true, message = "Message broadcasted successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost("send-to-user")]
        public async Task<IActionResult> SendToUser([FromBody] SendToUserRequest request)
        {
            try
            {
                await _hubContext.Clients.User(request.UserId).SendAsync("TestMessage", request.Message);
                return Ok(new { success = true, message = "Message sent to user successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }

    public class BroadcastRequest
    {
        public string Message { get; set; } = string.Empty;
    }

    public class SendToUserRequest
    {
        public string UserId { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
    }
}


