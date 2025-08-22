using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UserAccountController : ControllerBase
    {
        private readonly IUserAccountService _userAccountService;

        public UserAccountController(IUserAccountService userAccountService)
        {
            _userAccountService = userAccountService;
        }

        [HttpGet("{userId}")]
        public async Task<IActionResult> GetUserProfile(int userId)
        {
            try
            {
                var profile = await _userAccountService.GetUserProfile(userId);
                return Ok(new { success = true, data = profile });
            }
            catch (ArgumentException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("Stats/{userId}")]
        public async Task<IActionResult> GetUserStatistics(int userId)
        {
            try
            {
                var statistics = await _userAccountService.GetUserStatistics(userId);
                return Ok(new { success = true, data = statistics });
            }
            catch (ArgumentException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("LoyaltyBonuses/{userId}")]
        public async Task<IActionResult> GetLoyaltyBonuses(int userId)
        {
            try
            {
                var bonuses = await _userAccountService.GetLoyaltyBonuses(userId);
                return Ok(new { success = true, data = bonuses });
            }
            catch (ArgumentException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPut("RedeemBonus/{bonusId}/{userId}")]
        public async Task<IActionResult> RedeemBonus(int bonusId, int userId)
        {
            try
            {
                var result = await _userAccountService.RedeemBonus(bonusId, userId);
                
                if (result)
                {
                    return Ok(new { success = true, message = "Bonus redeemed successfully" });
                }
                else
                {
                    return BadRequest(new { success = false, message = "Bonus not available or already redeemed" });
                }
            }
            catch (ArgumentException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost("CalculatePoints")]
        public async Task<IActionResult> CalculatePoints([FromBody] CalculatePointsRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var points = await _userAccountService.CalculatePoints(request);
                return Ok(new { success = true, data = new { Points = points } });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("LoyaltyDiscount/{userId}")]
        public async Task<IActionResult> GetLoyaltyDiscount(int userId)
        {
            try
            {
                var discount = await _userAccountService.CalculateLoyaltyDiscount(userId);
                return Ok(new { success = true, data = new { LoyaltyDiscount = discount } });
            }
            catch (ArgumentException ex)
            {
                return NotFound(new { success = false, message = ex.Message });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }
}
