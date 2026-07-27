using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public interface IPaymentService : ICRUDService<Model.Payment, PaymentSearchObject, PaymentInsertRequest, PaymentUpdateRequest>
    {
        Task<Model.Payment> UpdatePaymentStatusAsync(int paymentId, string status);
        Task<List<Model.Payment>> GetPaymentsByOrderIdAsync(int orderId);
        Task<List<Model.Payment>> GetPaymentsByStatusAsync(string status);
        Task<decimal> GetTotalPaymentsAsync(DateTime? fromDate = null, DateTime? toDate = null);
        Task<bool> ValidatePaymentAsync(PaymentInsertRequest request);
        Task<object> CreateStripePaymentIntentAsync(CreateStripeIntentRequest request);
        Task<Model.Payment> ConfirmStripePaymentAsync(ConfirmStripePaymentRequest request);
        Task HandleStripeWebhookAsync(string json, string stripeSignatureHeader);
    }
}
