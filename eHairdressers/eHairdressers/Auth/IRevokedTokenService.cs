using System;
using System.Threading.Tasks;

namespace eHairdressers.Auth
{
    public interface IRevokedTokenService
    {
        Task RevokeAsync(string jti, DateTime expiresAtUtc);
        Task<bool> IsRevokedAsync(string jti);
    }
}
