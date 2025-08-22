using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Services
{
    public class SalonOperationsReportService : ISalonOperationsReportService
    {
        private readonly eHairdressersContext _context;

        public SalonOperationsReportService(eHairdressersContext context)
        {
            _context = context;
        }

        public async Task<SalonOperationsReport> GetSalonOperationsReport(SalonOperationsReportRequest request)
        {
            var report = new SalonOperationsReport
            {
                ReportId = 1, 
                ReportDate = DateTime.Now,
                StartDate = request.StartDate,
                EndDate = request.EndDate,
                ReportPeriod = request.ReportPeriod
            };

            
            var customerStats = await GetCustomerStatistics(request.StartDate, request.EndDate);
            report.TotalCustomers = customerStats.TotalCustomers;
            report.NewCustomers = customerStats.NewCustomers;
            report.ReturningCustomers = customerStats.ReturningCustomers;

            
            var appointmentStats = await GetAppointmentStatistics(request.StartDate, request.EndDate);
            report.TotalAppointments = appointmentStats.TotalAppointments;
            report.CompletedAppointments = appointmentStats.CompletedAppointments;
            report.CancelledAppointments = appointmentStats.CancelledAppointments;
            report.NoShowAppointments = appointmentStats.NoShowAppointments;

            
            var totalRevenue = await GetRevenueStatistics(request.StartDate, request.EndDate);
            report.TotalRevenue = totalRevenue;
            report.AverageAppointmentValue = appointmentStats.TotalAppointments > 0 
                ? totalRevenue / appointmentStats.TotalAppointments 
                : 0;

            
            report.DailyOperations = await GetDailyOperationsData(request.StartDate, request.EndDate);

            
            report.ServicePerformance = await GetServicePerformanceData(request.StartDate, request.EndDate);

            return report;
        }

        public async Task<List<SalonOperationsReport>> GetSalonOperationsReportHistory(DateTime startDate, DateTime endDate)
        {
            var reports = new List<SalonOperationsReport>();
            var currentDate = startDate;

            while (currentDate <= endDate)
            {
                var periodEnd = GetPeriodEndDate(currentDate, "monthly");
                if (periodEnd > endDate) periodEnd = endDate;

                var request = new SalonOperationsReportRequest
                {
                    StartDate = currentDate,
                    EndDate = periodEnd,
                    ReportPeriod = "monthly"
                };

                var report = await GetSalonOperationsReport(request);
                reports.Add(report);

                currentDate = periodEnd.AddDays(1);
            }

            return reports;
        }

        public async Task<object> GetSalonOperationsSummary(SalonOperationsReportRequest request)
        {
            var report = await GetSalonOperationsReport(request);

            return new
            {
                ReportId = report.ReportId,
                ReportDate = report.ReportDate,
                TotalCustomers = report.TotalCustomers,
                NewCustomers = report.NewCustomers,
                ReturningCustomers = report.ReturningCustomers,
                TotalRevenue = report.TotalRevenue,
                CompletedAppointments = report.CompletedAppointments,
                CancelledAppointments = report.CancelledAppointments,
                NoShowAppointments = report.NoShowAppointments,
                AverageAppointmentValue = report.AverageAppointmentValue,
                TotalAppointments = report.TotalAppointments,
                ReportPeriod = report.ReportPeriod,
                StartDate = report.StartDate,
                EndDate = report.EndDate
            };
        }

        private async Task<(int TotalCustomers, int NewCustomers, int ReturningCustomers)> GetCustomerStatistics(DateTime startDate, DateTime endDate)
        {
            
            var totalCustomers = await _context.Appointments
                .Where(a => a.AppointmentDate >= startDate && a.AppointmentDate <= endDate)
                .Select(a => a.UserId)
                .Distinct()
                .CountAsync();

            
            var newCustomers = await _context.Appointments
                .Where(a => a.AppointmentDate >= startDate && a.AppointmentDate <= endDate)
                .GroupBy(a => a.UserId)
                .Where(g => g.Min(a => a.AppointmentDate) >= startDate)
                .CountAsync();

            var returningCustomers = totalCustomers - newCustomers;

            return (totalCustomers, newCustomers, returningCustomers);
        }

        private async Task<(int TotalAppointments, int CompletedAppointments, int CancelledAppointments, int NoShowAppointments)> GetAppointmentStatistics(DateTime startDate, DateTime endDate)
        {
            var appointments = await _context.Appointments
                .Where(a => a.AppointmentDate >= startDate && a.AppointmentDate <= endDate)
                .ToListAsync();

            var totalAppointments = appointments.Count;
            var completedAppointments = appointments.Count(a => a.Approved == true);
            var cancelledAppointments = appointments.Count(a => a.Approved == false);
            var noShowAppointments = appointments.Count(a => a.Approved == null);

            return (totalAppointments, completedAppointments, cancelledAppointments, noShowAppointments);
        }

        private async Task<decimal> GetRevenueStatistics(DateTime startDate, DateTime endDate)
        {
            
            
            var completedAppointments = await _context.Appointments
                .Where(a => a.AppointmentDate >= startDate && a.AppointmentDate <= endDate && a.Approved == true)
                .CountAsync();

            return completedAppointments * 50.00m; 
        }

        private async Task<List<DailyOperationsData>> GetDailyOperationsData(DateTime startDate, DateTime endDate)
        {
            
            var appointments = await _context.Appointments
                .Where(a => a.AppointmentDate >= startDate && a.AppointmentDate <= endDate)
                .ToListAsync();

            
            var dailyData = appointments
                .GroupBy(a => a.AppointmentDate.Date)
                .Select(g => new DailyOperationsData
                {
                    Date = g.Key,
                    Appointments = g.Count(),
                    CompletedAppointments = g.Count(a => a.Approved == true),
                    CancelledAppointments = g.Count(a => a.Approved == false),
                    NoShowAppointments = g.Count(a => a.Approved == null),
                    Revenue = g.Count(a => a.Approved == true) * 50.00m, // Default price per service
                    NewCustomers = g.Where(a => a.AppointmentDate == g.Min(ap => ap.AppointmentDate))
                                   .Select(a => a.UserId)
                                   .Distinct()
                                   .Count()
                })
                .ToList();


            var allDates = Enumerable.Range(0, (endDate - startDate).Days + 1)
                                   .Select(d => startDate.AddDays(d).Date);

            var result = new List<DailyOperationsData>();
            foreach (var date in allDates)
            {
                var existingData = dailyData.FirstOrDefault(d => d.Date == date);
                result.Add(existingData ?? new DailyOperationsData
                {
                    Date = date,
                    Appointments = 0,
                    CompletedAppointments = 0,
                    CancelledAppointments = 0,
                    NoShowAppointments = 0,
                    Revenue = 0,
                    NewCustomers = 0
                });
            }

            return result.OrderBy(d => d.Date).ToList();
        }

        private async Task<List<ServicePerformanceData>> GetServicePerformanceData(DateTime startDate, DateTime endDate)
        {
            
            var appointmentsWithServices = await _context.Appointments
                .Where(a => a.AppointmentDate >= startDate && a.AppointmentDate <= endDate)
                .Join(_context.Services, a => a.ServiceId, s => s.ServiceId, (a, s) => new { a, s })
                .ToListAsync();

            
            var appointmentIds = appointmentsWithServices.Select(x => x.a.AppointmentId).ToList();
            var reviews = await _context.Reviews
                .Where(r => appointmentIds.Contains(r.AppointmentId) && r.Rate.HasValue)
                .ToListAsync();

            
            var serviceData = appointmentsWithServices
                .GroupBy(x => new { x.s.ServiceId, x.s.ServiceName })
                .Select(g => new ServicePerformanceData
                {
                    ServiceId = g.Key.ServiceId,
                    ServiceName = g.Key.ServiceName,
                    TotalBookings = g.Count(),
                    TotalRevenue = g.Count(x => x.a.Approved == true) * 50.00m, 
                    CompletedBookings = g.Count(x => x.a.Approved == true),
                    AverageRating = (decimal)reviews
                        .Where(r => g.Any(x => x.a.AppointmentId == r.AppointmentId))
                        .Select(r => r.Rate.Value)
                        .DefaultIfEmpty(0)
                        .Average()
                })
                .ToList();

            return serviceData;
        }

        private DateTime GetPeriodEndDate(DateTime startDate, string period)
        {
            return period switch
            {
                "daily" => startDate,
                "weekly" => startDate.AddDays(6),
                "monthly" => startDate.AddMonths(1).AddDays(-1),
                "yearly" => startDate.AddYears(1).AddDays(-1),
                _ => startDate.AddMonths(1).AddDays(-1)
            };
        }

        public async Task<object> GetSalonOperationsFocusedSummary(SalonOperationsReportRequest request)
        {
            var report = await GetSalonOperationsReport(request);

            return new
            {
                ReportId = report.ReportId,
                ReportDate = report.ReportDate,
                ReportPeriod = report.ReportPeriod,
                KeyMetrics = new
                {
                    TotalRevenue = report.TotalRevenue,
                    TotalAppointments = report.TotalAppointments,
                    CompletionRate = report.TotalAppointments > 0 
                        ? Math.Round((decimal)report.CompletedAppointments / report.TotalAppointments * 100, 2)
                        : 0,
                    AverageAppointmentValue = report.AverageAppointmentValue,
                    CustomerGrowth = report.NewCustomers > 0 
                        ? Math.Round((decimal)report.NewCustomers / report.TotalCustomers * 100, 2)
                        : 0
                },
                PerformanceSummary = new
                {
                    CompletedAppointments = report.CompletedAppointments,
                    CancelledAppointments = report.CancelledAppointments,
                    NoShowAppointments = report.NoShowAppointments,
                    TotalCustomers = report.TotalCustomers,
                    NewCustomers = report.NewCustomers,
                    ReturningCustomers = report.ReturningCustomers
                }
            };
        }
    }
}
