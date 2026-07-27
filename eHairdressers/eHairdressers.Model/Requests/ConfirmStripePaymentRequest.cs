using System.Text.Json.Serialization;

namespace eHairdressers.Model.Requests
{
    public class ConfirmStripePaymentRequest
    {
        [JsonPropertyName("orderId")]
        public int OrderId { get; set; }

        [JsonPropertyName("paymentIntentId")]
        public string PaymentIntentId { get; set; } = null!;
    }
}
