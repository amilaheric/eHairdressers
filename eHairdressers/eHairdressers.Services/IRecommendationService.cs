using eHairdressers.Model;

namespace eHairdressers.Services
{
    public interface IRecommendationService
    {
        
        Task<List<ProductRecommendation>> GetProductRecommendations(RecommendationRequest request);

        
        Task<List<UserSimilarity>> FindSimilarUsers(int userId, int numberOfSimilarUsers = 10);

        
        Task CalculateAndStoreUserSimilarities();

        
        Task<List<UserBehavior>> GetUserBehavior(int userId);

        
        Task<List<ProductRecommendation>> GetPopularProducts(int numberOfProducts = 10);

        
        Task<List<ProductRecommendation>> GetRecommendationsForNewUser(int numberOfProducts = 10);

            
        Task UpdateUserPreferences(int userId);

        
        Task<List<ProductRecommendation>> GetCategoryBasedRecommendations(int userId, int numberOfProducts = 10);
    }
}
