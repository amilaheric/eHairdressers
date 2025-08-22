using eHairdressers.Model.Requests;
using eHairdressers.Services.Database;

namespace eHairdressers.Services
{
    public interface IEmployeeService
    {
        Task<(int userId, int employeeId)> CreateEmployee(CreateEmployeeRequest request);
        Task<List<Employees>> GetAllEmployees();
        Task<Employees?> GetEmployeeById(int employeeId);
        Task<bool> UpdateEmployee(int employeeId, CreateEmployeeRequest request);
        Task<bool> DeleteEmployee(int employeeId);
    }
}
