using eHairdressers.Model;

namespace eHairdressers.Services
{
    public interface IUserRoleService
    {
        Task<List<string>> GetUserRoles(int userId);
        Task<bool> HasRole(int userId, string roleName);
        Task<bool> IsCustomer(int userId);
        Task<bool> IsAdmin(int userId);
        Task<bool> IsEmployee(int userId);
        Task AddRoleToUser(int userId, string roleName);
        Task RemoveRoleFromUser(int userId, string roleName);
    }
}


