using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.Json.Serialization;

namespace eHairdressers.Model.Requests
{
    public class OrdersInsertRequest
    {
        [JsonPropertyName("orderId")]
        public int? OrderId { get; set; }
        
        [JsonPropertyName("orderNumber")]
        public string? OrderNumber { get; set; }
        
        [JsonPropertyName("CustomerId")]
        public int CustomerId { get; set; }
        
        [JsonPropertyName("UserId")]
        public int UserId { get; set; }
        
        [JsonPropertyName("date")]
        public DateTime? Date { get; set; }
        
        [JsonPropertyName("status")]
        public bool Status { get; set; }
        
        [JsonPropertyName("canceled")]
        public bool Canceled { get; set; }
        
        [JsonPropertyName("paymentId")]
        public int? PaymentId { get; set; }
        
        [JsonPropertyName("totalPrice")]
        public double TotalPrice { get; set; }
        
        [JsonPropertyName("TotalWithVAT")]
        public double TotalWithVAT { get; set; }
        
        [JsonPropertyName("OrderItems")]
        public List<OrderItemsInsertRequest> OrderItems { get; set; } = new List<OrderItemsInsertRequest>();
    }
}
