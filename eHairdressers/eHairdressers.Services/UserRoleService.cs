using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Services
{
    public class UserRoleService : IUserRoleService
    {
        private readonly eHairdressersContext _context;

        public UserRoleService(eHairdressersContext context)
        {
            _context = context;
        }

        public async Task<List<string>> GetUserRoles(int userId)
        {
            var roles = await _context.UserRole
                .Where(ur => ur.UserId == userId)
                .Include(ur => ur.Role)
                .Select(ur => ur.Role.Name)
                .ToListAsync();

            return roles;
        }

        public async Task<bool> HasRole(int userId, string roleName)
        {
            var hasRole = await _context.UserRole
                .AnyAsync(ur => ur.UserId == userId && ur.Role.Name == roleName);

            return hasRole;
        }

        public async Task<bool> IsCustomer(int userId)
        {
            return await HasRole(userId, "Customer");
        }

        public async Task<bool> IsAdmin(int userId)
        {
            return await HasRole(userId, "Admin");
        }

        public async Task<bool> IsEmployee(int userId)
        {
            return await HasRole(userId, "Employee");
        }

        public async Task AddRoleToUser(int userId, string roleName)
        {
                    
            var role = await _context.Role.FirstOrDefaultAsync(r => r.Name == roleName);
            if (role == null)
            {
                throw new Exception($"Role '{roleName}' not found");
            }


            var existingUserRole = await _context.UserRole
                .FirstOrDefaultAsync(ur => ur.UserId == userId && ur.RoleId == role.RoleId);

            if (existingUserRole == null)
            {
                var userRole = new UserRole
                {
                    UserId = userId,
                    RoleId = role.RoleId,
                    DateChange = DateTime.Now
                };

                _context.UserRole.Add(userRole);
                await _context.SaveChangesAsync();
            }
        }

        public async Task RemoveRoleFromUser(int userId, string roleName)
        {
            var userRole = await _context.UserRole
                .Include(ur => ur.Role)
                .FirstOrDefaultAsync(ur => ur.UserId == userId && ur.Role.Name == roleName);

            if (userRole != null)
            {
                _context.UserRole.Remove(userRole);
                await _context.SaveChangesAsync();
            }
        }
    }
}


