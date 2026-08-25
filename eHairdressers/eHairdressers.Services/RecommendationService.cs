using AutoMapper;
using eHairdressers.Model;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public class RecommendationService : IRecommendationService
    {
        private readonly eHairdressersContext _context;
        private readonly IMapper _mapper;
        private readonly Dictionary<int, Dictionary<int, double>> _userSimilarityCache;
        private readonly Dictionary<int, Dictionary<int, double>> _userPreferences;

        public RecommendationService(eHairdressersContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
            _userSimilarityCache = new Dictionary<int, Dictionary<int, double>>();
            _userPreferences = new Dictionary<int, Dictionary<int, double>>();
        }

        public async Task<List<ProductRecommendation>> GetProductRecommendations(RecommendationRequest request)
        {
            var recommendations = new List<ProductRecommendation>();

           
            var userPurchases = await _context.OrderItems
                .Where(oi => oi.Order.UserId == request.UserId)
                .Include(oi => oi.Order)
                .Include(oi => oi.Product)
                .ToListAsync();

            if (!userPurchases.Any())
            {
               
                return await GetRecommendationsForNewUser(request.NumberOfRecommendations);
            }

           
            var similarUsers = await FindSimilarUsers(request.UserId, 20);

           
            var targetUserProductIds = userPurchases.Select(p => p.ProductId).ToHashSet();
            
            var similarUserPurchases = await _context.OrderItems
                .Where(oi => similarUsers.Select(su => su.SimilarUserId).Contains(oi.Order.UserId))
                .Include(oi => oi.Order)
                .Include(oi => oi.Product)
                .ThenInclude(p => p.Category)
                .Include(oi => oi.Product)
                .ThenInclude(p => p.Brand)
                .ToListAsync();

           
            var productScores = new Dictionary<int, (double Score, List<string> SimilarUsers, string ProductName)>();

            foreach (var purchase in similarUserPurchases)
            {
                if (targetUserProductIds.Contains(purchase.ProductId))
                    continue;

                var similarity = similarUsers.FirstOrDefault(su => su.SimilarUserId == purchase.Order.UserId);
                if (similarity == null) continue;

                var score = similarity.SimilarityScore * purchase.Quantity * purchase.Price;
                
                if (!productScores.ContainsKey(purchase.ProductId))
                {
                    productScores[purchase.ProductId] = (0, new List<string>(), purchase.Product?.Name ?? "Unknown Product");
                }

                var current = productScores[purchase.ProductId];
                current.Score += score;
                current.SimilarUsers.Add($"User {purchase.Order.UserId}");
                productScores[purchase.ProductId] = current;
            }

           
            recommendations = productScores
                .OrderByDescending(ps => ps.Value.Score)
                .Take(request.NumberOfRecommendations)
                .Select(ps => 
                {
                    var product = similarUserPurchases.FirstOrDefault(p => p.ProductId == ps.Key)?.Product;
                    return new ProductRecommendation
                    {
                        ProductId = ps.Key,
                        ProductName = ps.Value.ProductName,
                        Description = product?.Description ?? "",
                        Price = product?.Price ?? 0,
                        Code = product?.Code ?? "",
                        CategoryId = product?.CategoryId ?? 0,
                        CategoryName = product?.Category?.Name ?? "",
                        BrandId = product?.BrandId ?? 0,
                        BrandName = product?.Brand?.Name ?? "",
                        Image = product?.Image,
                        ImageThumb = product?.ImageThumb,
                        RecommendationScore = ps.Value.Score,
                        Reason = $"Recommended by {ps.Value.SimilarUsers.Count} similar users",
                        SimilarUsers = request.IncludeSimilarUsers ? ps.Value.SimilarUsers : new List<string>()
                    };
                })
                .ToList();

            return recommendations;
        }

        public async Task<List<UserSimilarity>> FindSimilarUsers(int userId, int numberOfSimilarUsers = 10)
        {
            var similarities = new List<UserSimilarity>();

           
            var targetUserPurchases = await _context.OrderItems
                .Where(oi => oi.Order.UserId == userId)
                .Include(oi => oi.Order)
                .ToListAsync();

            if (!targetUserPurchases.Any())
                return similarities;

           
            var otherUsers = await _context.OrderItems
                .Where(oi => oi.Order.UserId != userId)
                .Select(oi => oi.Order.UserId)
                .Distinct()
                .ToListAsync();

            foreach (var otherUserId in otherUsers)
            {
                var otherUserPurchases = await _context.OrderItems
                    .Where(oi => oi.Order.UserId == otherUserId)
                    .Include(oi => oi.Order)
                    .ToListAsync();

                var similarity = CalculateCosineSimilarity(targetUserPurchases, otherUserPurchases);
                
                if (similarity > 0)
                {
                    similarities.Add(new UserSimilarity
                    {
                        UserId = userId,
                        SimilarUserId = otherUserId,
                        SimilarityScore = similarity,
                        CalculatedDate = DateTime.UtcNow
                    });
                }
            }

            return similarities
                .OrderByDescending(s => s.SimilarityScore)
                .Take(numberOfSimilarUsers)
                .ToList();
        }

        public async Task CalculateAndStoreUserSimilarities()
        {
           
            _userSimilarityCache.Clear();
        }

        public async Task<List<UserBehavior>> GetUserBehavior(int userId)
        {
            var behaviors = new List<UserBehavior>();

            var userPurchases = await _context.OrderItems
                .Where(oi => oi.Order.UserId == userId)
                .Include(oi => oi.Product)
                .Include(oi => oi.Order)
                .GroupBy(oi => oi.ProductId)
                .ToListAsync();

            foreach (var group in userPurchases)
            {
                var productId = group.Key;
                var purchases = group.ToList();

               
                var reviews = await _context.Reviews
                    .Where(r => r.UserId == userId)
                    .Join(_context.Appointments.Where(a => a.UserId == userId),
                          r => r.AppointmentId,
                          a => a.AppointmentId,
                          (r, a) => r)
                    .ToListAsync();

                var averageRating = reviews.Any() ? reviews.Average(r => r.Rate ?? 0) : 0;

                behaviors.Add(new UserBehavior
                {
                    UserId = userId,
                    ProductId = productId,
                    PurchaseCount = purchases.Count,
                    TotalSpent = (decimal)purchases.Sum(p => p.Quantity * p.Price),
                    LastPurchaseDate = purchases.Max(p => p.Order.OrderDate),
                    AverageRating = averageRating,
                    ReviewCount = reviews.Count
                });
            }

            return behaviors.OrderByDescending(b => b.PurchaseCount).ToList();
        }

        public async Task<List<ProductRecommendation>> GetPopularProducts(int numberOfProducts = 10)
        {
            var popularProducts = await _context.OrderItems
                .Include(oi => oi.Product)
                .ThenInclude(p => p.Category)
                .Include(oi => oi.Product)
                .ThenInclude(p => p.Brand)
                .GroupBy(oi => oi.ProductId)
                .Select(g => new
                {
                    ProductId = g.Key,
                    TotalPurchases = g.Count(),
                    TotalRevenue = g.Sum(p => p.Quantity * p.Price),
                    Product = g.First().Product
                })
                .OrderByDescending(p => p.TotalPurchases)
                .ThenByDescending(p => p.TotalRevenue)
                .Take(numberOfProducts)
                .ToListAsync();

            return popularProducts.Select(p => new ProductRecommendation
            {
                ProductId = p.ProductId,
                ProductName = p.Product?.Name ?? "Unknown Product",
                Description = p.Product?.Description ?? "",
                Price = p.Product?.Price ?? 0,
                Code = p.Product?.Code ?? "",
                CategoryId = p.Product?.CategoryId ?? 0,
                CategoryName = p.Product?.Category?.Name ?? "",
                BrandId = p.Product?.BrandId ?? 0,
                BrandName = p.Product?.Brand?.Name ?? "",
                Image = p.Product?.Image,
                ImageThumb = p.Product?.ImageThumb,
                RecommendationScore = p.TotalPurchases,
                Reason = $"Popular product with {p.TotalPurchases} purchases"
            }).ToList();
        }

        public async Task<List<ProductRecommendation>> GetRecommendationsForNewUser(int numberOfProducts = 10)
        {
           
            var popularProducts = await GetPopularProducts(numberOfProducts / 2);

           
            var highlyRatedProducts = await _context.Reviews
                .Where(r => r.Rate.HasValue && r.Rate >= 4)
                .Join(_context.Appointments,
                      r => r.AppointmentId,
                      a => a.AppointmentId,
                      (r, a) => new { r.Rate, a.ServiceId })
                .GroupBy(x => x.ServiceId)
                .Select(g => new
                {
                    ServiceId = g.Key,
                    AverageRating = g.Average(x => x.Rate ?? 0),
                    ReviewCount = g.Count()
                })
                .Where(x => x.ReviewCount >= 3)
                .OrderByDescending(x => x.AverageRating)
                .Take(numberOfProducts / 2)
                .ToListAsync();

            var highlyRatedRecommendations = highlyRatedProducts.Select(p => new ProductRecommendation
            {
                ProductId = p.ServiceId, 
                ProductName = $"Highly Rated Service {p.ServiceId}",
                Description = "Highly rated service based on customer reviews",
                Price = 0, 
                Code = $"SERVICE_{p.ServiceId}",
                CategoryId = 0,
                CategoryName = "Services",
                BrandId = 0,
                BrandName = "Salon Services",
                        Image = null, 
                ImageThumb = null,
                RecommendationScore = p.AverageRating,
                Reason = $"Highly rated with {p.AverageRating:F1} stars from {p.ReviewCount} reviews"
            }).ToList();

            return popularProducts.Concat(highlyRatedRecommendations)
                .Take(numberOfProducts)
                .ToList();
        }

        public async Task UpdateUserPreferences(int userId)
        {
            var userPurchases = await _context.OrderItems
                .Where(oi => oi.Order.UserId == userId)
                .Include(oi => oi.Order)
                .ToListAsync();

            if (!_userPreferences.ContainsKey(userId))
                _userPreferences[userId] = new Dictionary<int, double>();

            foreach (var purchase in userPurchases)
            {
                var score = purchase.Quantity * purchase.Price;
                _userPreferences[userId][purchase.ProductId] = score;
            }
        }

        public async Task<List<ProductRecommendation>> GetCategoryBasedRecommendations(int userId, int numberOfProducts = 10)
        {
            
            var userCategoryPreferences = await _context.OrderItems
                .Where(oi => oi.Order.UserId == userId)
                .Join(_context.Products,
                      oi => oi.ProductId,
                      p => p.Id,
                      (oi, p) => new { TotalAmount = oi.Quantity * oi.Price, p.CategoryId })
                .GroupBy(x => x.CategoryId)
                .Select(g => new
                {
                    CategoryId = g.Key,
                    TotalSpent = g.Sum(x => x.TotalAmount)
                })
                .OrderByDescending(x => x.TotalSpent)
                .Take(3)
                .ToListAsync();

            if (!userCategoryPreferences.Any())
                return await GetPopularProducts(numberOfProducts);

            var preferredCategoryIds = userCategoryPreferences.Select(cp => cp.CategoryId).ToList();

            
            var userPurchasedProductIds = await _context.OrderItems
                .Where(oi => oi.Order.UserId == userId)
                .Select(oi => oi.ProductId)
                .ToListAsync();

            var recommendations = await _context.Products
                .Include(p => p.Category)
                .Include(p => p.Brand)
                .Where(p => preferredCategoryIds.Contains(p.CategoryId) && 
                           !userPurchasedProductIds.Contains(p.Id))
                .Take(numberOfProducts)
                .ToListAsync();

            var result = recommendations.Select(p => 
            {
                var categoryPreference = userCategoryPreferences.FirstOrDefault(cp => cp.CategoryId == p.CategoryId);
                return new ProductRecommendation
                {
                    ProductId = p.Id,
                    ProductName = p.Name,
                    Description = p.Description,
                    Price = p.Price,
                    Code = p.Code,
                    CategoryId = p.CategoryId,
                    CategoryName = p.Category?.Name ?? "",
                    BrandId = p.BrandId,
                    BrandName = p.Brand?.Name ?? "",
                    Image = p.Image,
                    ImageThumb = p.ImageThumb,
                    RecommendationScore = (double)(categoryPreference?.TotalSpent ?? 0),
                    Reason = $"Based on your preference for this category"
                };
            }).ToList();

            return result.OrderByDescending(r => r.RecommendationScore).ToList();
        }

        private double CalculateCosineSimilarity(List<Database.OrderItems> user1Purchases, List<Database.OrderItems> user2Purchases)
        {
            
            var allProductIds = user1Purchases.Select(p => p.ProductId)
                .Union(user2Purchases.Select(p => p.ProductId))
                .Distinct()
                .ToList();

            var user1Vector = new Dictionary<int, double>();
            var user2Vector = new Dictionary<int, double>();

            
            foreach (var productId in allProductIds)
            {
                user1Vector[productId] = 0;
                user2Vector[productId] = 0;
            }

            
            foreach (var purchase in user1Purchases)
            {
                user1Vector[purchase.ProductId] = purchase.Quantity * purchase.Price;
            }

            
            foreach (var purchase in user2Purchases)
            {
                user2Vector[purchase.ProductId] = purchase.Quantity * purchase.Price;
            }

                                
            double dotProduct = 0;
            double norm1 = 0;
            double norm2 = 0;

            foreach (var productId in allProductIds)
            {
                var val1 = user1Vector[productId];
                var val2 = user2Vector[productId];

                dotProduct += val1 * val2;
                norm1 += val1 * val1;
                norm2 += val2 * val2;
            }

            if (norm1 == 0 || norm2 == 0)
                return 0;

            return dotProduct / (Math.Sqrt(norm1) * Math.Sqrt(norm2));
        }
    }
}
