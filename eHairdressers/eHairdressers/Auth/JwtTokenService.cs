using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using eHairdressers.Model;
using eHairdressers.Model.Responses;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace eHairdressers.Auth
{
    public class JwtTokenService : IJwtTokenService
    {
        private readonly JwtOptions _options;

        public JwtTokenService(IOptions<JwtOptions> options)
        {
            _options = options.Value;

            if (string.IsNullOrWhiteSpace(_options.Key))
            {
                throw new InvalidOperationException(
                    "Jwt:Key is not configured. Set the JWT_SECRET_KEY value in .env (mapped to Jwt__Key in docker-compose.yml / appsettings for local runs).");
            }
        }

        public LoginResponse GenerateToken(User user)
        {
            var roles = user.UserRoles.Select(ur => ur.Role.Name).Distinct().ToList();
            var jti = Guid.NewGuid().ToString();
            var expiresAt = DateTime.UtcNow.AddMinutes(_options.ExpiryMinutes);

            var claims = new List<Claim>
            {
                // UserId lives in NameIdentifier so controllers can always read the
                // *current* user from the token instead of trusting a route/body value.
                new Claim(ClaimTypes.NameIdentifier, user.UserId.ToString()),
                new Claim(ClaimTypes.Name, user.Name),
                new Claim("username", user.Username),
                new Claim(JwtRegisteredClaimNames.Jti, jti),
            };

            claims.AddRange(roles.Select(role => new Claim(ClaimTypes.Role, role)));

            var keyBytes = Encoding.UTF8.GetBytes(_options.Key);
            var signingCredentials = new SigningCredentials(
                new SymmetricSecurityKey(keyBytes), SecurityAlgorithms.HmacSha256);

            var token = new JwtSecurityToken(
                issuer: _options.Issuer,
                audience: _options.Audience,
                claims: claims,
                expires: expiresAt,
                signingCredentials: signingCredentials);

            return new LoginResponse
            {
                Token = new JwtSecurityTokenHandler().WriteToken(token),
                ExpiresAtUtc = expiresAt,
                UserId = user.UserId,
                Username = user.Username,
                Name = user.Name,
                Email = user.Email,
                Roles = roles
            };
        }
    }
}
