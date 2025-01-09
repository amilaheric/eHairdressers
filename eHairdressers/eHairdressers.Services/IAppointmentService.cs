using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public interface IAppointmentService:ICRUDService<Model.Appointment, AppointmentsSearchObject, AppointmentInsertRequest, AppointmentUpdateRequest>
    {
        Task<List<Model.Appointment>> GetAppointmentsByUserIdAsync(int userId);
        Task<List<TimeSpan>> GetAvailableTimes(DateTime date);
    }
}
