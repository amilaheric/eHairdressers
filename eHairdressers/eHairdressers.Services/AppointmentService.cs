using AutoMapper;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using eHairdressers.Services.ProductsStateMachine;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public class AppointmentService : BaseCRUDService<Model.Appointment,Database.Appointment,AppointmentsSearchObject,AppointmentInsertRequest, AppointmentUpdateRequest>,IAppointmentService
    {
        public AppointmentService(eHairdressersContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<List<Model.Appointment>> GetAppointmentsByUserIdAsync(int userId)
        {
            var entity = await _context.Appointments.Where(a => a.UserId == userId).ToListAsync();
            return _mapper.Map<List<Model.Appointment>>(entity);
        }
        public override IQueryable<Appointment> AddInclude(IQueryable<Appointment> query, AppointmentsSearchObject? search = null)
        {
            query = query.Include(a => a.Employee)
                 .Include(a => a.Service)
                 .Include(a => a.User);

            return base.AddInclude(query, search);
        }

        public override IQueryable<Appointment> AddFilter(IQueryable<Appointment> query, AppointmentsSearchObject? search = null)
        {
          
                var filteredQuery = base.AddFilter(query, search);

                if (search?.AppointmentDate != null)
                {
                DateTime searchDate = search.AppointmentDate.Date;

                filteredQuery = filteredQuery.Where(x => x.AppointmentDate.Date == searchDate);

            }

            return filteredQuery;
            
        }

        public async Task<List<TimeSpan>> GetAvailableTimes(DateTime date)
        {
            var appointmentsForDate = await _context.Appointments
                .Where(a => a.AppointmentDate.Date == date.Date)
                .ToListAsync();

            var bookedTimes = appointmentsForDate.Select(a => a.AppointmentTime).ToList();


            List<TimeSpan> availableTimes = new List<TimeSpan>();

            TimeSpan startTime = new TimeSpan(8, 0, 0);
            TimeSpan endTime = new TimeSpan(17, 0, 0);


            for (TimeSpan time = startTime; time < endTime; time = time.Add(new TimeSpan(1, 0, 0)))
            {
                if (!bookedTimes.Contains(time))
                {
                    availableTimes.Add(time);
                }
            }

          
            return availableTimes;
        }

    }
}
