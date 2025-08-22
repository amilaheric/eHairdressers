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
        Task<Model.Payment> ProcessPaymentAsync(PaymentInsertRequest request);
        Task<Model.Payment> UpdatePaymentStatusAsync(int paymentId, string status);
        Task<List<Model.Payment>> GetPaymentsByOrderIdAsync(int orderId);
        Task<List<Model.Payment>> GetPaymentsByStatusAsync(string status);
        Task<decimal> GetTotalPaymentsAsync(DateTime? fromDate = null, DateTime? toDate = null);
        Task<bool> ValidatePaymentAsync(PaymentInsertRequest request);
    }
}
