using AutoMapper;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using eHairdressers.Model.Messages;

using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public class OrdersService : BaseCRUDService<Model.Orders, Database.Orders, OrdersSearchObject, OrdersInsertRequest, OrdersUpdateRequest>, IOrdersService
    {
        private readonly IMessagingService _messagingService;

        public OrdersService(eHairdressersContext context, IMapper mapper, IMessagingService messagingService) : base(context, mapper)
        {
            _messagingService = messagingService;
        }

        public override async Task BeforeInsert(Database.Orders entity, OrdersInsertRequest insert)
        {
          
            int userIdToUse = insert.CustomerId > 0 ? insert.CustomerId : insert.UserId;
            
            if (userIdToUse <= 0)
            {
                var firstUser = await _context.User.FirstOrDefaultAsync();
                if (firstUser != null)
                {
                    userIdToUse = firstUser.UserId;
                }
                else
                {
                    throw new InvalidOperationException("No users exist in the database. Please create a user first before creating orders.");
                }
            }
            else
            {
                var userExists = await _context.User.AnyAsync(u => u.UserId == userIdToUse);
                if (!userExists)
                {
                    throw new InvalidOperationException($"User with ID {userIdToUse} does not exist. Please check if the user is registered.");
                }
            }

            entity.UserId = userIdToUse;
            
          
            entity.TotalPrice = insert.TotalWithVAT;
            
            
        }

        public override async Task AfterInsert(Database.Orders entity, OrdersInsertRequest insert)
        {
 
            if (insert.OrderItems != null && insert.OrderItems.Any())
            {
             
                foreach (var orderItemRequest in insert.OrderItems)
                {
                    var orderItem = new Database.OrderItems
                    {
                        OrderId = entity.OrderId,
                        ProductId = orderItemRequest.ProductId,
                        Quantity = orderItemRequest.Quantity,
                        Price = orderItemRequest.Price
                    };
                    
                    _context.OrderItems.Add(orderItem);
                                     }
                
                await _context.SaveChangesAsync();
            
                
            
                await SendOrderCreatedMessageAsync(entity, insert.OrderItems);
             
            }
            else
            {
                Console.WriteLine($"DEBUG: No order items in request for order {entity.OrderId}");
            }
        }

        public override IQueryable<Database.Orders> AddInclude(IQueryable<Database.Orders> query, OrdersSearchObject? search = null)
        {
            query = query.Include(o => o.User);
            return base.AddInclude(query, search);
        }

        public override IQueryable<Database.Orders> AddFilter(IQueryable<Database.Orders> query, OrdersSearchObject? search = null)
        {
            if (search?.UserId != null)
            {
                query = query.Where(o => o.UserId == search.UserId);
            }

            return base.AddFilter(query, search);
        }

        public override IQueryable<Database.Orders> AddSorting(IQueryable<Database.Orders> query, OrdersSearchObject? search = null)
        {
            if (string.IsNullOrEmpty(search?.SortBy))
            {
                // Default: most recent orders first
                return query.OrderByDescending(o => o.OrderDate);
            }

            return base.AddSorting(query, search);
        }


        public async Task UpdateOrderTotalPrice(int orderId)
        {
            var order = await _context.Orders.FindAsync(orderId);
            if (order == null)
                return;

            var totalPrice = await _context.OrderItems
                .Where(oi => oi.OrderId == orderId)
                .SumAsync(oi => oi.Price * oi.Quantity);

            order.TotalPrice = totalPrice;
            await _context.SaveChangesAsync();
        }


        public async Task<double> GetOrderTotalPrice(int orderId)
        {
            var totalPrice = await _context.OrderItems
                .Where(oi => oi.OrderId == orderId)
                .SumAsync(oi => oi.Price * oi.Quantity);

            return totalPrice;
        }


        public async Task RecalculateAllOrderTotals()
        {
            var orders = await _context.Orders.ToListAsync();
            
            foreach (var order in orders)
            {
                await UpdateOrderTotalPrice(order.OrderId);
            }
        }



        private async Task SendOrderCreatedMessageAsync(Database.Orders order, List<OrderItemsInsertRequest> orderItems)
        {
            try
            {
                var user = await _context.User.FindAsync(order.UserId);
             
                
                var message = new OrderCreatedMessage
                {
                    OrderId = order.OrderId,
                    OrderNumber = order.OrderNumber,
                    UserId = order.UserId,
                    UserName = user?.Name + " " + user?.Surname,
                    UserEmail = user?.Email,
                    TotalPrice = order.TotalPrice,
                    OrderDate = order.OrderDate,
                    OrderItems = orderItems?.Select(oi => new OrderItemMessage
                    {
                        ProductId = oi.ProductId,
                        ProductName = "", 
                        Quantity = oi.Quantity,
                        Price = oi.Price
                    }).ToList() ?? new List<OrderItemMessage>()
                };

           
                
                await _messagingService.PublishOrderCreatedAsync(message);
                

            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error sending order created message: {ex.Message}");
            
            }
        }
    }
}
