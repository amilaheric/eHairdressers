using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.Json.Serialization;

namespace eHairdressers.Model.Requests
{
    public class PaymentUpdateRequest
    {
        [JsonPropertyName("paymentStatus")]
        public string? PaymentStatus { get; set; }
        
        [JsonPropertyName("paymentMethod")]
        public string? PaymentMethod { get; set; }
        
        [JsonPropertyName("amount")]
        public decimal? Amount { get; set; }
    }
}

