using AutoMapper;
using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public class PaymentService : BaseCRUDService<Model.Payment, Database.Payment, PaymentSearchObject, PaymentInsertRequest, PaymentUpdateRequest>, IPaymentService
    {
        public PaymentService(eHairdressersContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public override async Task BeforeInsert(Database.Payment entity, PaymentInsertRequest insert)
        {
           
            var orderExists = await _context.Orders.AnyAsync(o => o.OrderId == insert.OrderId);
            if (!orderExists)
            {
                throw new InvalidOperationException($"Order with ID {insert.OrderId} does not exist.");
            }

           
            if (insert.Amount <= 0)
            {
                throw new InvalidOperationException("Payment amount must be greater than zero.");
            }

           
            entity.PaymentDate = DateTime.Now;
            
           
            entity.PaymentStatus = "Pending";
        }

        public async Task<Model.Payment> ProcessPaymentAsync(PaymentInsertRequest request)
        {
           
            if (request.Amount <= 0)
            {
                throw new InvalidOperationException("Payment amount must be greater than zero.");
            }

           
            var paymentResult = await SimulateSimplePaymentAsync(request);
            
            if (paymentResult)
            {
                request.PaymentMethod = "Credit Card";
            }

           
            return await Insert(request);
        }

        public async Task<Model.Payment> UpdatePaymentStatusAsync(int paymentId, string status)
        {
            var payment = await _context.Payments.FindAsync(paymentId);
            if (payment == null)
            {
                throw new InvalidOperationException($"Payment with ID {paymentId} does not exist.");
            }

            payment.PaymentStatus = status;
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Payment>(payment);
        }

        public async Task<List<Model.Payment>> GetPaymentsByOrderIdAsync(int orderId)
        {
            var payments = await _context.Payments
                .Where(p => p.OrderId == orderId)
                .Include(p => p.Order)
                .ToListAsync();

            return _mapper.Map<List<Model.Payment>>(payments);
        }

        public async Task<List<Model.Payment>> GetPaymentsByStatusAsync(string status)
        {
            var payments = await _context.Payments
                .Where(p => p.PaymentStatus == status)
                .Include(p => p.Order)
                .ToListAsync();

            return _mapper.Map<List<Model.Payment>>(payments);
        }

        public async Task<decimal> GetTotalPaymentsAsync(DateTime? fromDate = null, DateTime? toDate = null)
        {
            var query = _context.Payments.Where(p => p.PaymentStatus == "Completed");

            if (fromDate.HasValue)
            {
                query = query.Where(p => p.PaymentDate >= fromDate.Value);
            }

            if (toDate.HasValue)
            {
                query = query.Where(p => p.PaymentDate <= toDate.Value);
            }

            return await query.SumAsync(p => p.Amount);
        }

        public async Task<bool> ValidatePaymentAsync(PaymentInsertRequest request)
        {
           
            if (request.Amount <= 0)
                return false;

            if (string.IsNullOrWhiteSpace(request.PaymentMethod))
                return false;

           
            var orderExists = await _context.Orders.AnyAsync(o => o.OrderId == request.OrderId);
            if (!orderExists)
                return false;

            return true;
        }

        private async Task<bool> SimulateSimplePaymentAsync(PaymentInsertRequest request)
        {
           
            await Task.Delay(500);

           
            var cardNumber = request.CardNumber?.Replace(" ", "").Replace("-", "") ?? "";
            
           
            if (cardNumber.EndsWith("0000"))
            {
               
                return false;
            }
            else if (cardNumber.EndsWith("1111"))
            {
               
                return true;
            }
            else
            {
                        
                return true;
            }
        }

        public override IQueryable<Database.Payment> AddInclude(IQueryable<Database.Payment> query, PaymentSearchObject? search = null)
        {
            query = query.Include(p => p.Order);
            return base.AddInclude(query, search);
        }

        public override IQueryable<Database.Payment> AddFilter(IQueryable<Database.Payment> query, PaymentSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (search?.OrderId != null)
            {
                filteredQuery = filteredQuery.Where(p => p.OrderId == search.OrderId);
            }

            if (!string.IsNullOrWhiteSpace(search?.PaymentStatus))
            {
                filteredQuery = filteredQuery.Where(p => p.PaymentStatus == search.PaymentStatus);
            }

            if (!string.IsNullOrWhiteSpace(search?.PaymentMethod))
            {
                filteredQuery = filteredQuery.Where(p => p.PaymentMethod == search.PaymentMethod);
            }

            if (search?.PaymentDateFrom != null)
            {
                filteredQuery = filteredQuery.Where(p => p.PaymentDate >= search.PaymentDateFrom);
            }

            if (search?.PaymentDateTo != null)
            {
                filteredQuery = filteredQuery.Where(p => p.PaymentDate <= search.PaymentDateTo);
            }

            if (search?.AmountMin != null)
            {
                filteredQuery = filteredQuery.Where(p => p.Amount >= search.AmountMin);
            }

            if (search?.AmountMax != null)
            {
                filteredQuery = filteredQuery.Where(p => p.Amount <= search.AmountMax);
            }

            return filteredQuery;
        }
    }
}
