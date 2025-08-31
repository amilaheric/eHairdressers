using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using eHairdressers.Services.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Controllers
{
    public class AppointmentController : BaseCRUDController<Model.Appointment, AppointmentsSearchObject, AppointmentInsertRequest, AppointmentUpdateRequest>
    {
        private readonly IAppointmentService _appointmentService;
        private readonly eHairdressersContext _context;

        public AppointmentController(ILogger<BaseController<Model.Appointment, AppointmentsSearchObject>> logger, IAppointmentService _service, eHairdressersContext context) : base(logger, _service)
        {
            _appointmentService = _service;
            _context = context;
        }


        [HttpGet("{userId}")]
        public virtual async Task<List<Model.Appointment>> GetAppointmentsByUserId(int userId)
        {
            return await _appointmentService.GetAppointmentsByUserIdAsync(userId);
        }

        [HttpGet("available-times")]
        public async Task<List<TimeSpan>> GetAvailableTimes(DateTime date)
        {
          return await _appointmentService.GetAvailableTimes(date);
        }

        [HttpGet("available-employees")]
        public async Task<List<Model.Employees>> GetAvailableEmployees()
        {
            return await _appointmentService.GetAvailableEmployees();
        }

        [HttpGet("available-users")]
        public async Task<List<Model.User>> GetAvailableUsers()
        {
            return await _appointmentService.GetAvailableUsers();
        }

        [HttpGet("available-services")]
        public async Task<List<Model.Service>> GetAvailableServices()
        {
            return await _appointmentService.GetAvailableServices();
        }



        [HttpPost]
        public override async Task<Model.Appointment> Insert([FromBody] AppointmentInsertRequest insert)
        {
            return await base.Insert(insert);
        }

        [HttpPut("cancel/{appointmentId}")]
        public async Task<IActionResult> CancelAppointment(int appointmentId)
        {
            try
            {
                // 1. Find the appointment
                var appointment = await _context.Appointments
                    .FirstOrDefaultAsync(a => a.AppointmentId == appointmentId);
                
                if (appointment == null)
                    return NotFound(new { success = false, message = "Appointment not found" });
                
                // 2. Update status to "Cancelled"
                appointment.Status = "Cancelled";
                
                // 3. Add cancellation comment
                appointment.Comment = appointment.Comment != null 
                    ? $"{appointment.Comment} [CANCELLED]" 
                    : "[CANCELLED]";
                
                // 4. Save changes
                await _context.SaveChangesAsync();
                
                // 5. Return success
                return Ok(new { success = true, message = "Appointment cancelled" });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { 
                    success = false, 
                    message = "An error occurred while cancelling the appointment",
                    error = ex.Message 
                });
            }
        }
    }
}
