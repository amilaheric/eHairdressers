using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Authorization;
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

        [HttpGet("order/{orderId}")]
        public async Task<List<Model.Payment>> GetPaymentsByOrderId(int orderId)
        {
            return await _paymentService.GetPaymentsByOrderIdAsync(orderId);
        }

        [HttpPost("create-stripe-intent")]
        public async Task<IActionResult> CreateStripeIntent([FromBody] CreateStripeIntentRequest request)
        {
            try
            {
                var result = await _paymentService.CreateStripePaymentIntentAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost("confirm-stripe-payment")]
        public async Task<IActionResult> ConfirmStripePayment([FromBody] ConfirmStripePaymentRequest request)
        {
            try
            {
                var payment = await _paymentService.ConfirmStripePaymentAsync(request);
                return Ok(payment);
            }
            catch (UnauthorizedAccessException ex)
            {
                return Forbid();
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    [HttpPost("stripe-webhook")]
        [AllowAnonymous]
        public async Task<IActionResult> StripeWebhook()
        {
            using var reader = new StreamReader(Request.Body);
            var json = await reader.ReadToEndAsync();

            try
            {
                await _paymentService.HandleStripeWebhookAsync(json, Request.Headers["Stripe-Signature"]);
                return Ok();
            }
            catch (Stripe.StripeException ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }
}
