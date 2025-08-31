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

            
            var totalAppointments = await GetAppointmentStatistics(request.StartDate, request.EndDate);
            report.TotalAppointments = totalAppointments;

            
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
                TotalAppointments = report.TotalAppointments,
                ReportPeriod = report.ReportPeriod,
                StartDate = report.StartDate,
                EndDate = report.EndDate
            };
        }

        private async Task<(int TotalCustomers, int NewCustomers)> GetCustomerStatistics(DateTime startDate, DateTime endDate)
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

            return (totalCustomers, newCustomers);
        }

        private async Task<int> GetAppointmentStatistics(DateTime startDate, DateTime endDate)
        {
            var totalAppointments = await _context.Appointments
                .Where(a => a.AppointmentDate >= startDate && a.AppointmentDate <= endDate)
                .CountAsync();

            return totalAppointments;
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
                    CompletedBookings = g.Count(x => x.a.Status == "Completed"),
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
                    TotalAppointments = report.TotalAppointments,
                    CompletionRate = 0, // Removed appointment status tracking
                    CustomerGrowth = report.NewCustomers > 0 
                        ? Math.Round((decimal)report.NewCustomers / report.TotalCustomers * 100, 2)
                        : 0
                },
                PerformanceSummary = new
                {
                    TotalCustomers = report.TotalCustomers,
                    NewCustomers = report.NewCustomers
                }
            };
        }
    }
}
