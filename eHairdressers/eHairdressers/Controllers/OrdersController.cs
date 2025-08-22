using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using eHairdressers.Services.Database;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Controllers
{
    public class OrdersController : BaseCRUDController<Model.Orders, OrdersSearchObject, OrdersInsertRequest, OrdersUpdateRequest>
    {
        private readonly eHairdressersContext _context;

        public OrdersController(ILogger<BaseController<Model.Orders, OrdersSearchObject>> _logger, IOrdersService _service, eHairdressersContext context) : base(_logger, _service)
        {
            _context = context;
        }

        [HttpPost]
        public override async Task<Model.Orders> Insert([FromBody] OrdersInsertRequest insert)
        {

            return await base.Insert(insert);
        }

        [HttpGet("available-users")]
        [AllowAnonymous]
        public async Task<object> GetAvailableUsers()
        {
            var users = await _context.User
                .Select(u => new { u.UserId, u.Name, u.Surname, u.Username })
                .ToListAsync();
            
            return new { users };
        }

        [HttpGet("check-users")]
        [AllowAnonymous]
        public async Task<object> CheckUsers()
        {
            var userCount = await _context.User.CountAsync();
            var firstUser = await _context.User.FirstOrDefaultAsync();
            
            return new { 
                userCount, 
                firstUserId = firstUser?.UserId,
                firstUserName = firstUser?.Name,
                message = userCount > 0 ? "Users exist in database" : "No users found in database"
            };
        }

        [HttpPost("recalculate-totals")]
        [AllowAnonymous]
        public async Task<IActionResult> RecalculateOrderTotals()
        {
            try
            {
                var ordersService = (IOrdersService)_service;
                await ordersService.RecalculateAllOrderTotals();
                
                return Ok(new { 
                    success = true, 
                    message = "All order totals have been recalculated successfully" 
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { 
                    success = false, 
                    message = $"Error recalculating order totals: {ex.Message}" 
                });
            }
        }


    }
}
