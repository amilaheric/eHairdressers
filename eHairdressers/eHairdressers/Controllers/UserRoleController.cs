using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using eHairdressers.Services;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class UserRoleController : ControllerBase
    {
        private readonly IUserRoleService _userRoleService;

        public UserRoleController(IUserRoleService userRoleService)
        {
            _userRoleService = userRoleService;
        }

        [HttpGet("user/{userId}/roles")]
        public async Task<IActionResult> GetUserRoles(int userId)
        {
            try
            {
                var roles = await _userRoleService.GetUserRoles(userId);
                return Ok(new { userId, roles });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("user/{userId}/has-role/{roleName}")]
        public async Task<IActionResult> HasRole(int userId, string roleName)
        {
            try
            {
                var hasRole = await _userRoleService.HasRole(userId, roleName);
                return Ok(new { userId, roleName, hasRole });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("user/{userId}/is-customer")]
        public async Task<IActionResult> IsCustomer(int userId)
        {
            try
            {
                var isCustomer = await _userRoleService.IsCustomer(userId);
                return Ok(new { userId, isCustomer });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("user/{userId}/is-admin")]
        public async Task<IActionResult> IsAdmin(int userId)
        {
            try
            {
                var isAdmin = await _userRoleService.IsAdmin(userId);
                return Ok(new { userId, isAdmin });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("user/{userId}/is-employee")]
        public async Task<IActionResult> IsEmployee(int userId)
        {
            try
            {
                var isEmployee = await _userRoleService.IsEmployee(userId);
                return Ok(new { userId, isEmployee });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("user/{userId}/add-role/{roleName}")]
        public async Task<IActionResult> AddRoleToUser(int userId, string roleName)
        {
            try
            {
                await _userRoleService.AddRoleToUser(userId, roleName);
                return Ok(new { message = $"Role '{roleName}' added to user {userId}" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpDelete("user/{userId}/remove-role/{roleName}")]
        public async Task<IActionResult> RemoveRoleFromUser(int userId, string roleName)
        {
            try
            {
                await _userRoleService.RemoveRoleFromUser(userId, roleName);
                return Ok(new { message = $"Role '{roleName}' removed from user {userId}" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("debug/current-user")]
        public async Task<IActionResult> GetCurrentUserInfo()
        {
            try
            {
                var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
                var username = User.FindFirst(System.Security.Claims.ClaimTypes.Name)?.Value;
                var roles = User.FindAll(System.Security.Claims.ClaimTypes.Role).Select(c => c.Value).ToList();
                
                return Ok(new { 
                    userId, 
                    username, 
                    roles,
                    isAuthenticated = User.Identity?.IsAuthenticated ?? false,
                    authenticationType = User.Identity?.AuthenticationType
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}

