using eHairdressers.Model.Requests;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;
using System.Security.Cryptography;
using System.Text;

namespace eHairdressers.Services
{
    public class EmployeeService : IEmployeeService
    {
        private readonly eHairdressersContext _context;

        public EmployeeService(eHairdressersContext context)
        {
            _context = context;
        }

        public async Task<(int userId, int employeeId)> CreateEmployee(CreateEmployeeRequest request)
        {
          
            
            using var transaction = _context.Database.BeginTransaction();
            try
            {
               
                var existingUser = await _context.User
                    .Where(u => u.Username == request.Username || u.CitizenshipNumber == request.CitizenshipNumber)
                    .Select(u => new { u.Username, u.CitizenshipNumber })
                    .FirstOrDefaultAsync();

                if (existingUser != null)
                {
                    if (existingUser.Username == request.Username)
                        throw new Exception("Username already exists");
                    if (existingUser.CitizenshipNumber == request.CitizenshipNumber)
                        throw new Exception("Citizenship number already exists");
                }

             
                var employeeRole = await _context.Role
                    .Where(r => r.Name == "Employee")
                    .Select(r => r.RoleId)
                    .FirstOrDefaultAsync();

                 
                if (employeeRole == 0)
                {
                    throw new Exception("Employee role not found in the system");
                }

               
                var user = new Database.User
                {
                    Name = request.Name,
                    Surname = request.Surname,
                    Email = request.Email,
                    BirthDate = request.BirthDate,
                    Address = request.Address,
                    CitizenshipNumber = request.CitizenshipNumber,
                    Phone = request.Phone,
                    Username = request.Username,
                    Status = true,
                    Image = request.Image
                };

               
                user.PasswordSalt = UserService.GenerateSalt();
                user.PasswordHash = UserService.GenerateHash(user.PasswordSalt, request.Password);

               
                var employee = new Database.Employees
                {
                    UserId = 0, 
                    Name = request.Name,
                    Surname = request.Surname,
                    HireDate = DateTime.Now,
                    BirthDate = request.BirthDate,
                    Address = request.Address,
                    CitizenshipNumber = request.CitizenshipNumber,
                    Phone = request.Phone,
                    Salary = request.Salary ?? 0
                };


                _context.User.Add(user);
                
                await _context.SaveChangesAsync();
                
               
                employee.UserId = user.UserId;
               
                
                _context.Employees.Add(employee);
                await _context.SaveChangesAsync();
                
               
                var userRole = new Database.UserRole
                {
                    UserId = user.UserId,
                    RoleId = employeeRole,
                    DateChange = DateTime.Now
                };

               
                _context.UserRole.Add(userRole);
                await _context.SaveChangesAsync();
                
               
                transaction.Commit();
               
                
                return (user.UserId, employee.EmployeeId);
            }
            catch (Exception ex)
            {
               
                transaction.Rollback();
               
                throw;
            }
        }

        public async Task<List<Employees>> GetAllEmployees()
        {
            return await _context.Employees
                .Include(e => e.User)  
                .OrderBy(e => e.Surname)
                .ThenBy(e => e.Name)
                .ToListAsync();
        }

        public async Task<Employees?> GetEmployeeById(int employeeId)
        {
            return await _context.Employees
                .Include(e => e.User)  
                .FirstOrDefaultAsync(e => e.EmployeeId == employeeId);
        }

        public async Task<bool> UpdateEmployee(int employeeId, CreateEmployeeRequest request)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var employee = await _context.Employees.FindAsync(employeeId);
                if (employee == null) return false;

               
                var user = await _context.User
                    .FirstOrDefaultAsync(u => u.CitizenshipNumber == employee.CitizenshipNumber);
                if (user == null) return false;

               
                if (request.Username != user.Username && 
                    await _context.User.AnyAsync(u => u.Username == request.Username))
                {
                    throw new Exception("Username already exists");
                }

               
                user.Name = request.Name;
                user.Surname = request.Surname;
                user.Email = request.Email;
                user.BirthDate = request.BirthDate;
                user.Address = request.Address;
                user.Phone = request.Phone;
                user.Username = request.Username;
                user.Image = request.Image;


                if (!string.IsNullOrEmpty(request.Password))
                {
                    user.PasswordSalt = UserService.GenerateSalt();
                    user.PasswordHash = UserService.GenerateHash(user.PasswordSalt, request.Password);
                }

               
                employee.Name = request.Name;
                employee.Surname = request.Surname;
                employee.BirthDate = request.BirthDate;
                employee.Address = request.Address;
                employee.Phone = request.Phone;
                employee.Salary = request.Salary ?? 0;

                await _context.SaveChangesAsync();
                transaction.Commit();
                return true;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }

        public async Task<bool> DeleteEmployee(int employeeId)
        {
            using var transaction = _context.Database.BeginTransaction();
            try
            {
                var employee = await _context.Employees.FindAsync(employeeId);
                if (employee == null) return false;

               
                var user = await _context.User
                    .FirstOrDefaultAsync(u => u.CitizenshipNumber == employee.CitizenshipNumber);
                if (user == null) return false;

               
                var userRoles = await _context.UserRole
                    .Where(ur => ur.UserId == user.UserId)
                    .ToListAsync();
                _context.UserRole.RemoveRange(userRoles);

                _context.Employees.Remove(employee);

               
                _context.User.Remove(user);

                await _context.SaveChangesAsync();
                transaction.Commit();
                return true;
            }
            catch
            {
                transaction.Rollback();
                throw;
            }
        }



    }
}
