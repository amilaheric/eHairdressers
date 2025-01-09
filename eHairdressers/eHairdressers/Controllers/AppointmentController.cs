using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    public class AppointmentController : BaseCRUDController<Model.Appointment, AppointmentsSearchObject, AppointmentInsertRequest, AppointmentUpdateRequest>
    {
        private readonly IAppointmentService _appointmentService;

        public AppointmentController(ILogger<BaseController<Appointment, AppointmentsSearchObject>> logger, IAppointmentService _service) : base(logger, _service)
        {
            _appointmentService = _service;
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

    }
}
