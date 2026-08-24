using eHairdressers.Model;
using eHairdressers.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class RecommendationController : ControllerBase
    {
        private readonly IRecommendationService _recommendationService;
        private readonly ILogger<RecommendationController> _logger;

        public RecommendationController(IRecommendationService recommendationService, ILogger<RecommendationController> logger)
        {
            _recommendationService = recommendationService;
            _logger = logger;
        }

     
        [HttpPost("recommendations")]
        public async Task<ActionResult<List<ProductRecommendation>>> GetProductRecommendations([FromBody] RecommendationRequest request)
        {
            try
            {
                var recommendations = await _recommendationService.GetProductRecommendations(request);
                return Ok(recommendations);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting product recommendations for user {UserId}", request.UserId);
                return StatusCode(500, "An error occurred while generating recommendations");
            }
        }

   
        [HttpGet("similar-users/{userId}")]
        public async Task<ActionResult<List<UserSimilarity>>> FindSimilarUsers(int userId, [FromQuery] int numberOfSimilarUsers = 10)
        {
            try
            {
                var similarUsers = await _recommendationService.FindSimilarUsers(userId, numberOfSimilarUsers);
                return Ok(similarUsers);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error finding similar users for user {UserId}", userId);
                return StatusCode(500, "An error occurred while finding similar users");
            }
        }

        [HttpGet("user-behavior/{userId}")]
        public async Task<ActionResult<List<UserBehavior>>> GetUserBehavior(int userId)
        {
            try
            {
                var behavior = await _recommendationService.GetUserBehavior(userId);
                return Ok(behavior);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting user behavior for user {UserId}", userId);
                return StatusCode(500, "An error occurred while analyzing user behavior");
            }
        }

        [HttpGet("popular-products")]
        public async Task<ActionResult<List<ProductRecommendation>>> GetPopularProducts([FromQuery] int numberOfProducts = 10)
        {
            try
            {
                var popularProducts = await _recommendationService.GetPopularProducts(numberOfProducts);
                return Ok(popularProducts);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting popular products");
                return StatusCode(500, "An error occurred while getting popular products");
            }
        }

        [HttpGet("new-user-recommendations")]
        public async Task<ActionResult<List<ProductRecommendation>>> GetRecommendationsForNewUser([FromQuery] int numberOfProducts = 10)
        {
            try
            {
                var recommendations = await _recommendationService.GetRecommendationsForNewUser(numberOfProducts);
                return Ok(recommendations);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting recommendations for new user");
                return StatusCode(500, "An error occurred while getting new user recommendations");
            }
        }


        [HttpPost("update-preferences/{userId}")]
        public async Task<ActionResult> UpdateUserPreferences(int userId)
        {
            try
            {
                await _recommendationService.UpdateUserPreferences(userId);
                return Ok("User preferences updated successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating preferences for user {UserId}", userId);
                return StatusCode(500, "An error occurred while updating user preferences");
            }
        }


        [HttpGet("category-recommendations/{userId}")]
        public async Task<ActionResult<List<ProductRecommendation>>> GetCategoryBasedRecommendations(int userId, [FromQuery] int numberOfProducts = 10)
        {
            try
            {
                var recommendations = await _recommendationService.GetCategoryBasedRecommendations(userId, numberOfProducts);
                return Ok(recommendations);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting category-based recommendations for user {UserId}", userId);
                return StatusCode(500, "An error occurred while getting category-based recommendations");
            }
        }

        [HttpPost("calculate-similarities")]
        public async Task<ActionResult> CalculateAndStoreUserSimilarities()
        {
            try
            {
                await _recommendationService.CalculateAndStoreUserSimilarities();
                return Ok("User similarities calculated and stored successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error calculating user similarities");
                return StatusCode(500, "An error occurred while calculating user similarities");
            }
        }
    }
}
