using System;
using System.Threading.Tasks;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Auth
{
    // Scoped (uses the request-scoped DbContext) - registered as Scoped in
    // Program.cs, never Transient, per the project's service-lifetime rule.
    public class RevokedTokenService : IRevokedTokenService
    {
        private readonly eHairdressersContext _context;

        public RevokedTokenService(eHairdressersContext context)
        {
            _context = context;
        }

        public async Task RevokeAsync(string jti, DateTime expiresAtUtc)
        {
            if (string.IsNullOrWhiteSpace(jti))
            {
                return;
            }

            var alreadyRevoked = await _context.RevokedTokens.AnyAsync(t => t.Jti == jti);
            if (alreadyRevoked)
            {
                return;
            }

            _context.RevokedTokens.Add(new RevokedToken
            {
                Jti = jti,
                ExpiresAtUtc = expiresAtUtc,
                RevokedAtUtc = DateTime.UtcNow
            });

            await _context.SaveChangesAsync();
        }

        public async Task<bool> IsRevokedAsync(string jti)
        {
            if (string.IsNullOrWhiteSpace(jti))
            {
                return false;
            }

            return await _context.RevokedTokens.AnyAsync(t => t.Jti == jti);
        }
    }
}
