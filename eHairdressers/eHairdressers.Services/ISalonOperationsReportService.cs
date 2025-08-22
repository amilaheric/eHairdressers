using eHairdressers.Model;
using eHairdressers.Model.Requests;

namespace eHairdressers.Services
{
    public interface ISalonOperationsReportService
    {
        Task<SalonOperationsReport> GetSalonOperationsReport(SalonOperationsReportRequest request);
        Task<List<SalonOperationsReport>> GetSalonOperationsReportHistory(DateTime startDate, DateTime endDate);
        Task<object> GetSalonOperationsSummary(SalonOperationsReportRequest request);
        Task<object> GetSalonOperationsFocusedSummary(SalonOperationsReportRequest request);
    }
}
