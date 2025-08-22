using eHairdressers.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.Extensions.Options;
using Microsoft.Identity.Client;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Encodings.Web;

namespace eHairdressers
{
    public class BasicAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
    {
        IUserService _userService;
        public BasicAuthenticationHandler(IUserService userService,IOptionsMonitor<AuthenticationSchemeOptions> options, ILoggerFactory logger, UrlEncoder encoder, ISystemClock clock) : base(options, logger, encoder, clock)
        {
            _userService = userService;
        }

        protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
        {
            if (!Request.Headers.ContainsKey("Authorization"))
            {
                Console.WriteLine("DEBUG: Missing Authorization header");
                return AuthenticateResult.Fail("Missing header");
            }

            var authHeader = AuthenticationHeaderValue.Parse(Request.Headers["Authorization"]);
            var credentialBytes = Convert.FromBase64String(authHeader.Parameter);
            var credentials = Encoding.UTF8.GetString(credentialBytes).Split(':');

            var username = credentials[0];
            var password = credentials[1];

            Console.WriteLine($"DEBUG: Attempting login for username: {username}");

            var user = await _userService.Login(username, password);

            if (user == null)
            {
                Console.WriteLine($"DEBUG: Login failed for username: {username}");
                return null;
            }

            if (username == null || password == null)
            {
                Console.WriteLine($"DEBUG: Username or password is null for: {username}");
                return AuthenticateResult.Fail("Incorrect username or password");
            } else
            {
                Console.WriteLine($"DEBUG: Login successful for user: {username}, UserRoles count: {user.UserRoles?.Count ?? 0}");
                
                var claims = new List<Claim>()
                {
                    new Claim(ClaimTypes.Name, user.Name),
                    new Claim(ClaimTypes.NameIdentifier, user.Username)
                };

                foreach(var role in user.UserRoles)
                {
                    claims.Add(new Claim(ClaimTypes.Role, role.Role.Name));
                    Console.WriteLine($"DEBUG: Added role claim: {role.Role.Name}");
                }

                var identity = new ClaimsIdentity(claims,Scheme.Name);
                var principals = new ClaimsPrincipal(identity);

                var ticket = new AuthenticationTicket(principals, Scheme.Name);

                return AuthenticateResult.Success(ticket);
            }
           
        }

    }
}
