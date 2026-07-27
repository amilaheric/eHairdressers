using System.Text.Json.Serialization;

namespace eHairdressers.Model.Requests
{
    public class CreateStripeIntentRequest
    {
        [JsonPropertyName("orderId")]
        public int OrderId { get; set; }

        [JsonPropertyName("amount")]
        public int Amount { get; set; } 

        [JsonPropertyName("currency")]
        public string Currency { get; set; } = "usd";
    }
}
