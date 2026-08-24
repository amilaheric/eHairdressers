using eHairdressers.Model;
using eHairdressers.Model.Responses;

namespace eHairdressers.Auth
{
    public interface IJwtTokenService
    {
        LoginResponse GenerateToken(User user);
    }
}
