using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.Json.Serialization;

namespace eHairdressers.Model.Requests
{
    public class PaymentInsertRequest
    {
        [JsonPropertyName("orderId")]
        public int OrderId { get; set; }
        
        [JsonPropertyName("amount")]
        public decimal Amount { get; set; }
        
        [JsonPropertyName("paymentMethod")]
        public string PaymentMethod { get; set; } = "Credit Card";
        
        [JsonPropertyName("cardNumber")]
        public string CardNumber { get; set; } = "1234567890123456"; 
    }
}
