using eHairdressers.Model;
using eHairdressers.Model.Requests;

namespace eHairdressers.Services
{
    public interface IUserAccountService
    {
        Task<UserProfile> GetUserProfile(int userId);
        Task<UserStatistics> GetUserStatistics(int userId);
        Task<List<LoyaltyBonus>> GetLoyaltyBonuses(int userId);
        Task<bool> RedeemBonus(int bonusId, int userId);
        Task<int> CalculatePoints(CalculatePointsRequest request);
        Task<string> GetLoyaltyTier(int userId);
        Task<decimal> GetTotalSpent(int userId);
        Task<decimal> CalculateLoyaltyDiscount(int userId);
    }
}
