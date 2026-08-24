using eHairdressers.Auth;
using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Authorization;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class UserController : BaseCRUDController<Model.User, UserSearchObject, UserInsertRequest,UserUpdateRequest>
    {
        private readonly IUserService _userService;
        private readonly IJwtTokenService _jwtTokenService;
        private readonly IRevokedTokenService _revokedTokenService;

        public UserController(
            ILogger<BaseController<User, UserSearchObject>> logger,
            IUserService service,
            IJwtTokenService jwtTokenService,
            IRevokedTokenService revokedTokenService) : base(logger, service)
        {
            _userService = service;
            _jwtTokenService = jwtTokenService;
            _revokedTokenService = revokedTokenService;
        }

        public override Task<User> Insert([FromBody] UserInsertRequest insert)
        {
            return base.Insert(insert);
        }

        // Credentials are always sent in the POST body, never as query string
        // parameters. This is the only endpoint that issues a JWT - every
        // other endpoint requires "Authorization: Bearer {token}".
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginRequest request)
        {
            if (request == null || string.IsNullOrWhiteSpace(request.Username) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new { success = false, message = "Username and password are required." });
            }

            var user = await _userService.Login(request.Username, request.Password);
            if (user == null)
            {
                return Unauthorized(new { success = false, message = "Incorrect username or password." });
            }

            var loginResponse = _jwtTokenService.GenerateToken(user);
            return Ok(loginResponse);
        }

        // Server-side logout: the token's jti is recorded as revoked so it is
        // rejected by JwtBearerEvents.OnTokenValidated (Program.cs) even if
        // the client keeps sending it. Simply discarding the token on the
        // client is not sufficient per the rubric.
        [HttpPost("logout")]
        [Authorize]
        public async Task<IActionResult> Logout()
        {
            try
            {
                var jti = User.FindFirstValue(JwtRegisteredClaimNames.Jti);
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                var username = User.FindFirst("username")?.Value;

                if (!string.IsNullOrEmpty(jti))
                {
                    var expiresAtUtc = DateTime.UtcNow.AddDays(1);
                    var expClaim = User.FindFirstValue(JwtRegisteredClaimNames.Exp);
                    if (!string.IsNullOrEmpty(expClaim) && long.TryParse(expClaim, out var expUnixSeconds))
                    {
                        expiresAtUtc = DateTimeOffset.FromUnixTimeSeconds(expUnixSeconds).UtcDateTime;
                    }

                    await _revokedTokenService.RevokeAsync(jti, expiresAtUtc);
                }

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
                var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                var username = User.FindFirst("username")?.Value;
                var name = User.FindFirst(ClaimTypes.Name)?.Value;
                var roles = User.FindAll(ClaimTypes.Role).Select(c => c.Value).ToList();

                return Ok(new {
                    success = true,
                    user = new {
                        userId = userId,
                        username = username,
                        name = name,
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
