using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Services.Database
{
    public static class SeedData
    {
        public static async Task SeedRoles(eHairdressersContext context)
        {
           
            if (await context.Role.AnyAsync())
                return;

            var roles = new List<Role>
            {
                new Role { Name = "Customer", Description = "Regular customer" },
                new Role { Name = "Employee", Description = "Salon employee" },
                new Role { Name = "Admin", Description = "System administrator" }
            };

            context.Role.AddRange(roles);
            await context.SaveChangesAsync();
        }

        public static async Task AssignDefaultRoleToUser(eHairdressersContext context, int userId, string roleName = "Customer")
        {
           
            var existingRoles = await context.UserRole
                .Where(ur => ur.UserId == userId)
                .AnyAsync();

            if (existingRoles)
                return;

           
            var role = await context.Role.FirstOrDefaultAsync(r => r.Name == roleName);
            if (role == null)
                return;

            var userRole = new UserRole
            {
                UserId = userId,
                RoleId = role.RoleId,
                DateChange = DateTime.Now
            };

            context.UserRole.Add(userRole);
            await context.SaveChangesAsync();
        }
    }
}


