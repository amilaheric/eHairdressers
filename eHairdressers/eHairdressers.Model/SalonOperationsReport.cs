namespace eHairdressers.Model
{
    public class SalonOperationsReport
    {
        public int ReportId { get; set; }
        public DateTime ReportDate { get; set; }
        public int TotalCustomers { get; set; }
        public int NewCustomers { get; set; }
        public int ReturningCustomers { get; set; }
        public decimal TotalRevenue { get; set; }
        public int TotalAppointments { get; set; }
        public int CompletedAppointments { get; set; }
        public int CancelledAppointments { get; set; }
        public int NoShowAppointments { get; set; }
        public decimal AverageAppointmentValue { get; set; }
        public string ReportPeriod { get; set; } = string.Empty;
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public List<DailyOperationsData> DailyOperations { get; set; } = new List<DailyOperationsData>();
        public List<ServicePerformanceData> ServicePerformance { get; set; } = new List<ServicePerformanceData>();
    }

    public class DailyOperationsData
    {
        public DateTime Date { get; set; }
        public int Appointments { get; set; }
        public int CompletedAppointments { get; set; }
        public int CancelledAppointments { get; set; }
        public int NoShowAppointments { get; set; }
        public decimal Revenue { get; set; }
        public int NewCustomers { get; set; }
    }

    public class ServicePerformanceData
    {
        public int ServiceId { get; set; }
        public string ServiceName { get; set; } = string.Empty;
        public int TotalBookings { get; set; }
        public decimal TotalRevenue { get; set; }
        public int CompletedBookings { get; set; }
        public decimal AverageRating { get; set; }
    }
}
