using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Text.Json.Serialization;

namespace eHairdressers.Model.Requests
{
    public class OrderItemsUpdateRequest
    {
        [JsonPropertyName("orderId")]
        public int? OrderId { get; set; }
        
        [JsonPropertyName("productId")]
        public int? ProductId { get; set; }
        
        [JsonPropertyName("amount")]
        public int? Amount { get; set; }
        
        [JsonPropertyName("quantity")]
        public int? Quantity { get; set; }
        
        [JsonPropertyName("price")]
        public double? Price { get; set; }
        
        [JsonPropertyName("total")]
        public double? Total { get; set; }
    }
}
