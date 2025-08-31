using AutoMapper;
using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using eHairdressers.Model.Messages;

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
        private readonly IMessagingService _messagingService;

        public AppointmentService(eHairdressersContext context, IMapper mapper, IMessagingService messagingService) : base(context, mapper)
        {
            _messagingService = messagingService;
        }

        public async Task<List<Model.Appointment>> GetAppointmentsByUserIdAsync(int userId)
        {
            var entity = await _context.Appointments
                .Where(a => a.UserId == userId)
                .Include(a => a.Employee)
                .Include(a => a.Service)
                .Include(a => a.User)
                .ToListAsync();
            return _mapper.Map<List<Model.Appointment>>(entity);
        }

        public override async Task BeforeInsert(Database.Appointment entity, AppointmentInsertRequest insert)
        {
           

          
            var employeeExists = await _context.Employees.AnyAsync(e => e.EmployeeId == insert.EmployeeId);
            if (!employeeExists)
            {
                throw new InvalidOperationException($"Employee with ID {insert.EmployeeId} does not exist. Please provide a valid Employee ID.");
            }

    
            var userExists = await _context.User.AnyAsync(u => u.UserId == insert.UserId);
            if (!userExists)
            {
                throw new InvalidOperationException($"User with ID {insert.UserId} does not exist. Please provide a valid User ID.");
            }

    
            var serviceExists = await _context.Services.AnyAsync(s => s.ServiceId == insert.ServiceId);
            if (!serviceExists)
            {
                throw new InvalidOperationException($"Service with ID {insert.ServiceId} does not exist. Please provide a valid Service ID.");
            }

            entity.Status = "Scheduled";
        }

        public override IQueryable<Database.Appointment> AddInclude(IQueryable<Database.Appointment> query, AppointmentsSearchObject? search = null)
        {
            query = query.Include(a => a.Employee)
               .Include(a => a.Service)
               .Include(a => a.User);

            return base.AddInclude(query, search);
        }

        public override IQueryable<Database.Appointment> AddFilter(IQueryable<Database.Appointment> query, AppointmentsSearchObject? search = null)
        {
           
            
            var filteredQuery = base.AddFilter(query, search);
        

            if (search?.AppointmentDate != null && search.AppointmentDate != DateTime.MinValue)
            {
                DateTime searchDate = search.AppointmentDate.Date;
                filteredQuery = filteredQuery.Where(x => x.AppointmentDate.Date == searchDate);
            
            }

            return filteredQuery;
        }

        public override async Task<PageResult<Model.Appointment>> Get(AppointmentsSearchObject? search = null)
        {
            var query = _context.Set<Database.Appointment>().AsQueryable();

            var result = new PageResult<Model.Appointment>();

            // First add includes to ensure navigation properties are loaded
            query = AddInclude(query, search);
            
            // Then apply filters
            query = AddFilter(query, search);

            result.Count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true) {
                query = query.Take(search.PageSize.Value).Skip(search.Page.Value * search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var tmp = _mapper.Map<List<Model.Appointment>>(list);
            
            result.Result = tmp;
            return result;
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


        public async Task<List<Model.Employees>> GetAvailableEmployees()
        {
            var employees = await _context.Employees.ToListAsync();
            return _mapper.Map<List<Model.Employees>>(employees);
        }

        public async Task<List<Model.User>> GetAvailableUsers()
        {
            var users = await _context.User.ToListAsync();
            return _mapper.Map<List<Model.User>>(users);
        }

        public async Task<List<Model.Service>> GetAvailableServices()
        {
            var services = await _context.Services.ToListAsync();
            return _mapper.Map<List<Model.Service>>(services);
        }

        public async Task<List<Model.Appointment>> GetCompletedAppointmentsForReviewAsync(int userId)
        {
            var today = DateTime.Today;
            
           
            var completedAppointments = await _context.Appointments
                .Include(a => a.Employee)
                .Include(a => a.Service)
                .Include(a => a.User)
                .Where(a => a.UserId == userId && a.AppointmentDate < today)
                .ToListAsync();

            var appointmentsWithoutReviews = new List<Database.Appointment>();
            
            foreach (var appointment in completedAppointments)
            {
                var hasReview = await _context.Reviews
                    .AnyAsync(r => r.AppointmentId == appointment.AppointmentId && r.UserId == userId);
                
                if (!hasReview)
                {
                    appointmentsWithoutReviews.Add(appointment);
                }
            }

            return _mapper.Map<List<Model.Appointment>>(appointmentsWithoutReviews);
        }

        public async Task<bool> CancelAppointmentAsync(int appointmentId)
        {
            try
            {
                var appointment = await _context.Appointments
                    .FirstOrDefaultAsync(a => a.AppointmentId == appointmentId);

                if (appointment == null)
                {
                    throw new InvalidOperationException($"Appointment with ID {appointmentId} not found.");
                }

                // Check if appointment is in the future
                var appointmentDateTime = appointment.AppointmentDate.Add(appointment.AppointmentTime);
                if (appointmentDateTime <= DateTime.Now)
                {
                    throw new InvalidOperationException("Cannot cancel past or current appointments.");
                }

                            // Update appointment status to cancelled
            appointment.Status = "Cancelled";
                
                // Add a comment indicating cancellation
                appointment.Comment = appointment.Comment != null 
                    ? $"{appointment.Comment} [CANCELLED]" 
                    : "[CANCELLED]";

                await _context.SaveChangesAsync();
                return true;
            }
            catch (Exception ex)
            {
                // Log the error (you can add proper logging here)
                Console.WriteLine($"Error cancelling appointment {appointmentId}: {ex.Message}");
                throw;
            }
        }

        public override async Task AfterInsert(Database.Appointment entity, AppointmentInsertRequest insert)
        {
             await SendAppointmentCreatedMessageAsync(entity);
           
        }

        private async Task SendAppointmentCreatedMessageAsync(Database.Appointment appointment)
        {
            try
            {
         
                var user = await _context.User.FindAsync(appointment.UserId);
                var employee = await _context.Employees.FindAsync(appointment.EmployeeId);
                var service = await _context.Services.FindAsync(appointment.ServiceId);

                var message = new AppointmentCreatedMessage
                {
                    AppointmentId = appointment.AppointmentId,
                    UserId = appointment.UserId,
                    UserName = user?.Name + " " + user?.Surname,
                    UserEmail = user?.Email,
                    EmployeeId = appointment.EmployeeId,
                    EmployeeName = employee?.Name + " " + employee?.Surname,
                    ServiceId = appointment.ServiceId,
                    ServiceName = service?.ServiceName,
                    AppointmentDate = appointment.AppointmentDate,
                    AppointmentTime = appointment.AppointmentTime,
                    Comment = appointment.Comment,
                    Status = appointment.Status
                };

                await _messagingService.PublishAppointmentCreatedAsync(message);
            }
            catch (Exception ex)
            {
               
                Console.WriteLine($"Error sending appointment created message: {ex.Message}");
            }
        }
    }
}
