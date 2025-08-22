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

    }
}
