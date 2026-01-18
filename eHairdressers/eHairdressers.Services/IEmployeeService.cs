using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;

namespace eHairdressers.Services
{
    public interface IEmployeeService : IService<Model.Employees, EmployeeSearchObject>
    {
        Task<(int userId, int employeeId)> CreateEmployee(CreateEmployeeRequest request);
        Task<List<Database.Employees>> GetAllEmployees();
        Task<Database.Employees?> GetEmployeeById(int employeeId);
        Task<bool> UpdateEmployee(int employeeId, CreateEmployeeRequest request);
        Task<bool> DeleteEmployee(int employeeId);
    }
}
