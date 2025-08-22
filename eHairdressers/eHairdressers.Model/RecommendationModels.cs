using System.ComponentModel.DataAnnotations;

namespace eHairdressers.Model
{
    public class UserSimilarity
    {
        public int UserId { get; set; }
        public int SimilarUserId { get; set; }
        public double SimilarityScore { get; set; }
        public DateTime CalculatedDate { get; set; }
    }

    public class ProductRecommendation
    {
        public int ProductId { get; set; }
        public string ProductName { get; set; }
        public string Description { get; set; }
        public double Price { get; set; }
        public string Code { get; set; }
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public int BrandId { get; set; }
        public string BrandName { get; set; }
        public byte[]? Image { get; set; }
        public byte[]? ImageThumb { get; set; }
        public double RecommendationScore { get; set; }
        public string Reason { get; set; }
        public List<string> SimilarUsers { get; set; } = new List<string>();
    }

    public class UserPreference
    {
        public int UserId { get; set; }
        public int ProductId { get; set; }
        public double PreferenceScore { get; set; }
        public DateTime LastUpdated { get; set; }
    }

    public class RecommendationRequest
    {
        public int UserId { get; set; }
        public int NumberOfRecommendations { get; set; } = 10;
        public bool IncludeSimilarUsers { get; set; } = true;
        public DateTime? FromDate { get; set; }
        public DateTime? ToDate { get; set; }
    }

    public class UserBehavior
    {
        public int UserId { get; set; }
        public int ProductId { get; set; }
        public int PurchaseCount { get; set; }
        public decimal TotalSpent { get; set; }
        public DateTime LastPurchaseDate { get; set; }
        public double AverageRating { get; set; }
        public int ReviewCount { get; set; }
    }
}
