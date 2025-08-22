using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Services
{
    public class UserAccountService : IUserAccountService
    {
        private readonly eHairdressersContext _context;

        public UserAccountService(eHairdressersContext context)
        {
            _context = context;
        }

        public async Task<UserProfile> GetUserProfile(int userId)
        {
            var user = await _context.User
                .Where(u => u.UserId == userId)
                .FirstOrDefaultAsync();

            if (user == null)
                throw new ArgumentException("User not found");

            var (totalSpent, loyaltyPoints, loyaltyTier, loyaltyDiscount) = await GetUserMetrics(userId);

            var appointments = await _context.Appointments
                .Where(a => a.UserId == userId)
                .ToListAsync();

            var orders = await _context.Orders
                .Where(o => o.UserId == userId)
                .ToListAsync();

            return new UserProfile
            {
                UserId = user.UserId,
                Name = user.Name,
                Surname = user.Surname,
                Email = user.Email ?? "",
                Phone = user.Phone ?? "",
                Username = user.Username,
                RegistrationDate = DateTime.Now,
                LastLoginDate = null,
                IsActive = user.Status ?? true,
                TotalAppointments = appointments.Count,
                CompletedAppointments = appointments.Count(a => a.Approved.HasValue && a.Approved.Value),
                TotalOrders = orders.Count,
                CompletedOrders = orders.Count(o => o.Status == true),
                TotalSpent = totalSpent,
                LoyaltyPoints = loyaltyPoints,
                LoyaltyTier = loyaltyTier,
                LoyaltyDiscount = loyaltyDiscount
            };
        }

        public async Task<UserStatistics> GetUserStatistics(int userId)
        {
            var appointments = await _context.Appointments
                .Where(a => a.UserId == userId)
                .ToListAsync();

            var orders = await _context.Orders
                .Where(o => o.UserId == userId)
                .ToListAsync();

            var (totalSpent, loyaltyPoints, loyaltyTier, loyaltyDiscount) = await GetUserMetrics(userId);

            return new UserStatistics
            {
                UserId = userId,
                TotalAppointments = appointments.Count,
                CompletedAppointments = appointments.Count(a => a.Approved.HasValue && a.Approved.Value),
                CancelledAppointments = appointments.Count(a => a.Approved.HasValue && !a.Approved.Value),
                NoShowAppointments = appointments.Count(a => !a.Approved.HasValue),
                TotalOrders = orders.Count,
                CompletedOrders = orders.Count(o => o.Status == true),
                CancelledOrders = orders.Count(o => o.Status == false),
                TotalSpent = totalSpent,
                AverageAppointmentValue = appointments.Count > 0 ? totalSpent / appointments.Count : 0,
                AverageOrderValue = orders.Count > 0 ? (decimal)orders.Average(o => o.TotalPrice) : 0,
                LoyaltyPoints = loyaltyPoints,
                LoyaltyTier = loyaltyTier,
                LoyaltyDiscount = loyaltyDiscount,
                FirstAppointment = appointments.Any() ? appointments.Min(a => a.AppointmentDate) : DateTime.MinValue,
                LastAppointment = appointments.Any() ? appointments.Max(a => a.AppointmentDate) : DateTime.MinValue,
                FirstOrder = orders.Any() ? orders.Min(o => o.OrderDate) : DateTime.MinValue,
                LastOrder = orders.Any() ? orders.Max(o => o.OrderDate) : DateTime.MinValue
            };
        }

        public async Task<List<LoyaltyBonus>> GetLoyaltyBonuses(int userId)
        {
            var (_, loyaltyPoints, _, _) = await GetUserMetrics(userId);
            var currentDate = DateTime.Now;
            var bonuses = new List<LoyaltyBonus>();

            if (loyaltyPoints >= 100)
            {
                bonuses.Add(new LoyaltyBonus
                {
                    BonusId = 1,
                    UserId = userId,
                    BonusType = "Discount",
                    Description = "10% off next appointment",
                    Value = 5.00m,
                    PointsRequired = 100,
                    ExpiryDate = currentDate.AddMonths(3),
                    IsRedeemed = false,
                    Status = "Available"
                });
            }

            if (loyaltyPoints >= 250)
            {
                bonuses.Add(new LoyaltyBonus
                {
                    BonusId = 2,
                    UserId = userId,
                    BonusType = "Free Service",
                    Description = "Free basic service",
                    Value = 25.00m,
                    PointsRequired = 250,
                    ExpiryDate = currentDate.AddMonths(6),
                    IsRedeemed = false,
                    Status = "Available"
                });
            }

            if (loyaltyPoints >= 500)
            {
                bonuses.Add(new LoyaltyBonus
                {
                    BonusId = 3,
                    UserId = userId,
                    BonusType = "Premium Discount",
                    Description = "20% off premium service",
                    Value = 15.00m,
                    PointsRequired = 500,
                    ExpiryDate = currentDate.AddMonths(12),
                    IsRedeemed = false,
                    Status = "Available"
                });
            }

            return bonuses;
        }

        public async Task<bool> RedeemBonus(int bonusId, int userId)
        {
            var bonuses = await GetLoyaltyBonuses(userId);
            return bonuses.Any(b => b.BonusId == bonusId);
        }

        public async Task<List<Achievement>> GetAchievements(int userId)
        {
            return new List<Achievement>();
        }

        public async Task<int> CalculatePoints(CalculatePointsRequest request)
        {
            return (int)(request.Amount * 0.1m);
        }

        public async Task<string> GetLoyaltyTier(int userId)
        {
            var (_, _, loyaltyTier, _) = await GetUserMetrics(userId);
            return loyaltyTier;
        }

        public async Task<decimal> GetTotalSpent(int userId)
        {
            var (totalSpent, _, _, _) = await GetUserMetrics(userId);
            return totalSpent;
        }

        public async Task<decimal> CalculateLoyaltyDiscount(int userId)
        {
            var (_, _, _, loyaltyDiscount) = await GetUserMetrics(userId);
            return loyaltyDiscount;
        }

        private async Task<(decimal totalSpent, int loyaltyPoints, string loyaltyTier, decimal loyaltyDiscount)> GetUserMetrics(int userId)
        {
            var completedAppointments = await _context.Appointments
                .Where(a => a.UserId == userId && a.Approved.HasValue && a.Approved.Value)
                .CountAsync();

            
            var allOrdersTotal = await _context.Orders
                .Where(o => o.UserId == userId)
                .SumAsync(o => (decimal)o.TotalPrice);

            
            var completedOrdersTotal = await _context.Orders
                .Where(o => o.UserId == userId && o.Status == true)
                .SumAsync(o => (decimal)o.TotalPrice);

            var appointmentSpent = completedAppointments * 50.00m;
            var totalSpent = appointmentSpent + allOrdersTotal;
            
                
            var appointmentPoints = completedAppointments * 10;
            var orderPoints = (int)(completedOrdersTotal / 10); 
            var loyaltyPoints = appointmentPoints + orderPoints;
            
            var loyaltyTier = totalSpent >= 1000 || completedAppointments >= 20 ? "Platinum" :
                             totalSpent >= 500 || completedAppointments >= 10 ? "Gold" :
                             totalSpent >= 200 || completedAppointments >= 5 ? "Silver" : "Bronze";

            var loyaltyDiscount = CalculateDiscount(completedAppointments, completedOrdersTotal > 0 ? 1 : 0);

            return (totalSpent, loyaltyPoints, loyaltyTier, loyaltyDiscount);
        }

        private static decimal CalculateDiscount(int appointments, int orders)
        {
            var baseDiscount = (appointments >= 5 || orders >= 1) ? 5.0m : 0;
            var additionalDiscount = Math.Max(0, (appointments - 5) / 5) * 2.0m;
            return Math.Min(baseDiscount + additionalDiscount, 25.0m);
        }
    }
}
