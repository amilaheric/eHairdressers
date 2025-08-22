using Microsoft.AspNetCore.Mvc;
using eHairdressers.Services;
using eHairdressers.Model.Messages;
using System;
using System.Threading.Tasks;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MessagingController : ControllerBase
    {
        private readonly IMessagingService _messagingService;

        public MessagingController(IMessagingService messagingService)
        {
            _messagingService = messagingService;
        }

        [HttpGet("status")]
        public async Task<IActionResult> GetConnectionStatus()
        {
            try
            {
                var isConnected = await _messagingService.IsConnectedAsync();
                return Ok(new { 
                    connected = isConnected, 
                    message = isConnected ? "RabbitMQ connected" : "RabbitMQ not connected" 
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }


    }
}
