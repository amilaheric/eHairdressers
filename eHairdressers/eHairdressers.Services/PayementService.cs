using AutoMapper;
using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Stripe;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public class PaymentService : BaseCRUDService<Model.Payment, Database.Payment, PaymentSearchObject, PaymentInsertRequest, PaymentUpdateRequest>, IPaymentService
    {
        private readonly IConfiguration _configuration;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public PaymentService(eHairdressersContext context, IMapper mapper, IConfiguration configuration, IHttpContextAccessor httpContextAccessor) : base(context, mapper)
        {
            _configuration = configuration;
            _httpContextAccessor = httpContextAccessor;

            var secretKey = _configuration["Stripe:SecretKey"];
            if (!string.IsNullOrEmpty(secretKey))
            {
                StripeConfiguration.ApiKey = secretKey;
            }
        }
        private async Task<Database.User?> GetCurrentUserAsync()
        {
            var username = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(username))
            {
                return null;
            }

            return await _context.User.FirstOrDefaultAsync(u => u.Username == username);
        }

        private bool IsPrivilegedCaller()
        {
            var user = _httpContextAccessor.HttpContext?.User;
            return user != null && (user.IsInRole("Employee") || user.IsInRole("Admin"));
        }
        private async Task EnsureCallerOwnsOrderAsync(Database.Orders order)
        {
            if (IsPrivilegedCaller())
            {
                return;
            }

            var currentUser = await GetCurrentUserAsync();
            if (currentUser == null || currentUser.UserId != order.UserId)
            {
                throw new UnauthorizedAccessException("You are not authorized to perform this action on this order.");
            }
        }

              private async Task<Database.Payment> UpsertPaymentFromIntentAsync(PaymentIntent paymentIntent, int orderId)
        {
            string paymentStatus = paymentIntent.Status switch
            {
                "succeeded" => "Completed",
                "canceled" => "Failed",
                "requires_payment_method" => "Failed",
                _ => "Pending"
            };

            var existing = await _context.Payments
                .FirstOrDefaultAsync(p => p.StripePaymentIntentId == paymentIntent.Id);

            Database.Payment paymentEntity;

            if (existing != null)
            {
                existing.PaymentStatus = paymentStatus;
                paymentEntity = existing;
            }
            else
            {
                paymentEntity = new Database.Payment
                {
                    OrderId = orderId,
                    PaymentDate = DateTime.Now,
                    Amount = paymentIntent.Amount / 100m,
                    PaymentMethod = "Stripe",
                    PaymentStatus = paymentStatus,
                    StripePaymentIntentId = paymentIntent.Id
                };

                _context.Payments.Add(paymentEntity);
            }

            if (paymentStatus == "Completed")
            {
                var order = await _context.Orders.FindAsync(orderId);
                if (order != null)
                {
                    order.Status = true;
                }
            }

            await _context.SaveChangesAsync();

            return paymentEntity;
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

        public async Task<object> CreateStripePaymentIntentAsync(CreateStripeIntentRequest request)
        {

            var order = await _context.Orders.FindAsync(request.OrderId);
            if (order == null)
            {
                throw new InvalidOperationException($"Order with ID {request.OrderId} does not exist.");
            }

            await EnsureCallerOwnsOrderAsync(order);

            if (order.TotalPrice <= 0)
            {
                throw new InvalidOperationException("Order total must be greater than zero.");
            }

            var secretKey = _configuration["Stripe:SecretKey"];
            if (string.IsNullOrEmpty(secretKey))
            {
                throw new InvalidOperationException("Stripe Secret Key is not configured. Please set Stripe:SecretKey in appsettings.json");
            }

            var currency = string.IsNullOrWhiteSpace(request.Currency) ? "usd" : request.Currency.ToLower();
            long amountInCents = (long)Math.Round(order.TotalPrice * 100, MidpointRounding.AwayFromZero);

            var options = new PaymentIntentCreateOptions
            {
                Amount = amountInCents,
                Currency = currency,
                Metadata = new Dictionary<string, string>
                {
                    { "orderId", request.OrderId.ToString() }
                },
                AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
                {
                    Enabled = true,
                },
            };

            var requestOptions = new RequestOptions
            {
                IdempotencyKey = $"create-intent-order-{request.OrderId}-{DateTime.UtcNow:yyyyMMddHHmm}"
            };

            var service = new PaymentIntentService();
            var paymentIntent = await service.CreateAsync(options, requestOptions);

            return new
            {
                clientSecret = paymentIntent.ClientSecret
            };
        }

        public async Task<Model.Payment> ConfirmStripePaymentAsync(ConfirmStripePaymentRequest request)
        {
            var order = await _context.Orders.FindAsync(request.OrderId);
            if (order == null)
            {
                throw new InvalidOperationException($"Order with ID {request.OrderId} does not exist.");
            }

            await EnsureCallerOwnsOrderAsync(order);

            var secretKey = _configuration["Stripe:SecretKey"];
            if (string.IsNullOrEmpty(secretKey))
            {
                throw new InvalidOperationException("Stripe Secret Key is not configured. Please set Stripe:SecretKey in appsettings.json");
            }

            var service = new PaymentIntentService();
            var paymentIntent = await service.GetAsync(request.PaymentIntentId);

            if (paymentIntent == null)
            {
                throw new InvalidOperationException($"Payment Intent with ID {request.PaymentIntentId} not found.");
            }

            if (paymentIntent.Metadata == null ||
                !paymentIntent.Metadata.TryGetValue("orderId", out var metadataOrderId) ||
                metadataOrderId != request.OrderId.ToString())
            {
                throw new InvalidOperationException("Payment Intent does not match the specified order.");
            }

            var paymentEntity = await UpsertPaymentFromIntentAsync(paymentIntent, request.OrderId);

            return _mapper.Map<Model.Payment>(paymentEntity);
        }

        public async Task HandleStripeWebhookAsync(string json, string stripeSignatureHeader)
        {
            var webhookSecret = _configuration["Stripe:WebhookSecret"];
            if (string.IsNullOrEmpty(webhookSecret))
            {
                throw new InvalidOperationException("Stripe Webhook Secret is not configured. Please set Stripe:WebhookSecret in appsettings.json");
            }

            var stripeEvent = EventUtility.ConstructEvent(json, stripeSignatureHeader, webhookSecret);

            if (stripeEvent.Type != "payment_intent.succeeded" && stripeEvent.Type != "payment_intent.payment_failed")
            {
                return;
            }

            var paymentIntent = stripeEvent.Data.Object as PaymentIntent;
            if (paymentIntent == null)
            {
                return;
            }

            if (paymentIntent.Metadata == null || !paymentIntent.Metadata.TryGetValue("orderId", out var orderIdString) ||
                !int.TryParse(orderIdString, out var orderId))
            {
                return;
            }

            var orderExists = await _context.Orders.AnyAsync(o => o.OrderId == orderId);
            if (!orderExists)
            {
                return;
            }

            await UpsertPaymentFromIntentAsync(paymentIntent, orderId);
        }
    }
}
