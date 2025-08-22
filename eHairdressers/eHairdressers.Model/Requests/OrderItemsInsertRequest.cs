using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.Json.Serialization;

namespace eHairdressers.Model.Requests
{
    public class OrderItemsInsertRequest
    {
        [JsonPropertyName("OrderId")]
        public int OrderId { get; set; }
        
        [JsonPropertyName("ProductId")]
        public int ProductId { get; set; }
        
        [JsonPropertyName("Amount")]
        public int Amount { get; set; }
        
        [JsonPropertyName("Quantity")]
        public int Quantity { get; set; }
        
        [JsonPropertyName("Price")]
        public double Price { get; set; }
        
        [JsonPropertyName("Total")]
        public double Total { get; set; }
    }
}
