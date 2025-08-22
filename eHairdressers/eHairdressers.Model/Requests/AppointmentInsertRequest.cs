using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.Json.Serialization;

namespace eHairdressers.Model.Requests
{
    public class AppointmentInsertRequest
    {
        [JsonPropertyName("employeeId")]
        public int EmployeeId { get; set; }
        
        [JsonPropertyName("employeeName")]
        public string? EmployeeName { get; set; }
        
        [JsonPropertyName("userId")]
        public int UserId { get; set; }
        
        [JsonPropertyName("username")]
        public string? Username { get; set; }
        
        [JsonPropertyName("serviceId")]
        public int ServiceId { get; set; }
        
        [JsonPropertyName("serviceName")]
        public string? ServiceName { get; set; }
        
        [JsonPropertyName("appointmentDate")]
        public DateTime? AppointmentDate { get; set; }
        
        [JsonPropertyName("appointmentTime")]
        public string? AppointmentTime { get; set; }
        
        [JsonPropertyName("comment")]
        public string? Comment { get; set; }
    }

}
