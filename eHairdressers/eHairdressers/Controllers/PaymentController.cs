using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    public class PaymentController : BaseCRUDController<Model.Payment, PaymentSearchObject, PaymentInsertRequest, PaymentUpdateRequest>
    {
        private readonly IPaymentService _paymentService;

        public PaymentController(ILogger<BaseController<Model.Payment, PaymentSearchObject>> logger, IPaymentService service) : base(logger, service)
        {
            _paymentService = service;
        }

        [HttpPost("process")]
        public async Task<Model.Payment> ProcessPayment([FromBody] PaymentInsertRequest request)
        {
            return await _paymentService.ProcessPaymentAsync(request);
        }

        [HttpGet("order/{orderId}")]
        public async Task<List<Model.Payment>> GetPaymentsByOrderId(int orderId)
        {
            return await _paymentService.GetPaymentsByOrderIdAsync(orderId);
        }

        [HttpGet("sample-cards")]
        public object GetSampleCards()
        {
            return new
            {
                successCards = new[]
                {
                    new { cardNumber = "1234567890121111", description = "Always succeeds" },
                    new { cardNumber = "1234567890123456", description = "Default test card" }
                },
                failureCards = new[]
                {
                    new { cardNumber = "1234567890120000", description = "Always fails" }
                }
            };
        }

        [HttpGet("test-payment")]
        public async Task<Model.Payment> TestPayment()
        {

            var testRequest = new PaymentInsertRequest
            {
                OrderId = 1, 
                Amount = 99.99m,
                PaymentMethod = "Credit Card",
                CardNumber = "1234567890121111"
            };

            return await _paymentService.ProcessPaymentAsync(testRequest);
        }
    }
}
