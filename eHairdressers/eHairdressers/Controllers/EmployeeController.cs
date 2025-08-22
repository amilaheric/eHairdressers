using Microsoft.AspNetCore.Mvc;
using eHairdressers.Model.Requests;
using eHairdressers.Services;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class EmployeeController : ControllerBase
    {
        private readonly IEmployeeService _employeeService;
        private readonly IUserRoleService _userRoleService;
        private readonly IUserService _userService;
        private readonly ILogger<EmployeeController> _logger;

        public EmployeeController(
            IEmployeeService employeeService, 
            IUserRoleService userRoleService,
            IUserService userService,
            ILogger<EmployeeController> logger)
        {
            _employeeService = employeeService;
            _userRoleService = userRoleService;
            _userService = userService;
            _logger = logger;
        }

        [HttpPost("CreateEmployee")]
        public async Task<IActionResult> CreateEmployee([FromBody] CreateEmployeeRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var (userId, employeeId) = await _employeeService.CreateEmployee(request);
                
                _logger.LogInformation("Employee created successfully. UserId: {UserId}, EmployeeId: {EmployeeId}", userId, employeeId);
                
                return Ok(new { 
                    success = true, 
                    message = "Employee created successfully",
                    userId = userId, 
                    employeeId = employeeId 
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating employee");
                return BadRequest(new { 
                    success = false, 
                    message = ex.Message 
                });
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetAllEmployees()
        {
            try
            {
                var employees = await _employeeService.GetAllEmployees();
                return Ok(new { 
                    success = true, 
                    data = employees 
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving employees");
                return BadRequest(new { 
                    success = false, 
                    message = ex.Message 
                });
            }
        }

        [HttpGet("{employeeId}")]
        public async Task<IActionResult> GetEmployeeById(int employeeId)
        {
            try
            {
                var employee = await _employeeService.GetEmployeeById(employeeId);
                if (employee == null)
                {
                    return NotFound(new { 
                        success = false, 
                        message = "Employee not found" 
                    });
                }

                return Ok(new { 
                    success = true, 
                    data = employee 
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving employee with ID: {EmployeeId}", employeeId);
                return BadRequest(new { 
                    success = false, 
                    message = ex.Message 
                });
            }
        }



        [HttpPut("{employeeId}")]
        public async Task<IActionResult> UpdateEmployee(int employeeId, [FromBody] CreateEmployeeRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var success = await _employeeService.UpdateEmployee(employeeId, request);
                if (!success)
                {
                    return NotFound(new { 
                        success = false, 
                        message = "Employee not found" 
                    });
                }

                _logger.LogInformation("Employee updated successfully. EmployeeId: {EmployeeId}", employeeId);
                
                return Ok(new { 
                    success = true, 
                    message = "Employee updated successfully" 
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error updating employee with ID: {EmployeeId}", employeeId);
                return BadRequest(new { 
                    success = false, 
                    message = ex.Message 
                });
            }
        }

        [HttpDelete("{employeeId}")]
        public async Task<IActionResult> DeleteEmployee(int employeeId)
        {
            try
            {
                var success = await _employeeService.DeleteEmployee(employeeId);
                if (!success)
                {
                    return NotFound(new { 
                        success = false, 
                        message = "Employee not found" 
                    });
                }

                _logger.LogInformation("Employee deleted successfully. EmployeeId: {EmployeeId}", employeeId);
                
                return Ok(new { 
                    success = true, 
                    message = "Employee deleted successfully" 
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting employee with ID: {EmployeeId}", employeeId);
                return BadRequest(new { 
                    success = false, 
                    message = ex.Message 
                });
            }
        }

        [HttpGet("debug/check-employee/{userId}")]
        public async Task<IActionResult> CheckEmployeeDatabaseState(int userId)
        {
            try
            {
           
                var employee = await _employeeService.GetEmployeeById(userId);
                if (employee == null)
                {
                    return NotFound(new { success = false, message = "Employee not found" });
                }

                var userRoles = await _userRoleService.GetUserRoles(userId);

                return Ok(new { 
                    success = true,
                    user = new {
                        userId = employee.User.UserId,
                        username = employee.User.Username,
                        status = employee.User.Status,
                        hasPasswordHash = !string.IsNullOrEmpty(employee.User.PasswordHash),
                        hasPasswordSalt = !string.IsNullOrEmpty(employee.User.PasswordSalt)
                    },
                    employee = new {
                        employeeId = employee.EmployeeId,
                        userId = employee.UserId,
                        name = employee.Name
                    },
                    userRoles = userRoles.Select(roleName => new {
                        roleName = roleName
                    }).ToList()
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking employee database state for UserId: {UserId}", userId);
                return BadRequest(new { 
                    success = false, 
                    message = ex.Message 
                });
            }
        }

        [HttpPost("debug/test-login")]
        public async Task<IActionResult> TestEmployeeLogin([FromBody] LoginTestRequest request)
        {
            try
            {
           
                var user = await _userService.Login(request.Username, request.Password);

                if (user == null)
                {
                    return NotFound(new { success = false, message = "User not found or invalid credentials" });
                }

       
                var userRoles = await _userRoleService.GetUserRoles(user.UserId);

                return Ok(new { 
                    success = true,
                    user = new {
                        userId = user.UserId,
                        username = user.Username,
                        status = user.Status
                    },
                    userRoles = userRoles.Select(roleName => new {
                        roleName = roleName
                    }).ToList()
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error testing employee login for Username: {Username}", request.Username);
                return BadRequest(new { 
                    success = false, 
                    message = ex.Message 
                });
            }
        }

    }
}
