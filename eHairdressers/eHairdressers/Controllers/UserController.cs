using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authorization;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<Model.User, UserSearchObject, UserInsertRequest,UserUpdateRequest>
    {
        public UserController(ILogger<BaseController<User, UserSearchObject>> logger,IUserService service) : base(logger, service)
        {
        }

        public override Task<User> Insert([FromBody] UserInsertRequest insert)
        {
            return base.Insert(insert);
        }

        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout()
        {
            try
            {
                // Get current user info before logout
                var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
                var username = User.FindFirst(System.Security.Claims.ClaimTypes.Name)?.Value;
                
                // For Basic Authentication, we just return success
                // The client should clear their stored credentials
                // No need to call SignOutAsync for Basic Auth
                
                return Ok(new { 
                    success = true, 
                    message = "User logged out successfully",
                    loggedOutUser = new {
                        userId = userId,
                        username = username
                    }
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { 
                    success = false, 
                    message = "Error during logout",
                    error = ex.Message 
                });
            }
        }

        [HttpGet("current-user")]
        [Authorize]
        public IActionResult GetCurrentUser()
        {
            try
            {
                var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
                var username = User.FindFirst(System.Security.Claims.ClaimTypes.Name)?.Value;
                var roles = User.FindAll(System.Security.Claims.ClaimTypes.Role).Select(c => c.Value).ToList();
                
                return Ok(new { 
                    success = true,
                    user = new {
                        userId = userId, 
                        username = username, 
                        roles = roles,
                        isAuthenticated = User.Identity?.IsAuthenticated ?? false,
                        authenticationType = User.Identity?.AuthenticationType
                    }
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { 
                    success = false, 
                    message = "Error getting current user info",
                    error = ex.Message 
                });
            }
        }
    }
}
