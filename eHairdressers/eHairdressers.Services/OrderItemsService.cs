using AutoMapper;
using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using eHairdressers.Model.Messages;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Services
{
    public class OrderItemsService : BaseCRUDService<Model.OrderItems, Database.OrderItems, OrderItemsSearchObject, OrderItemsInsertRequest, OrderItemsUpdateRequest>, IOrderItemsService
    {
        private readonly IMessagingService _messagingService;

        public OrderItemsService(eHairdressersContext context, IMapper mapper, IMessagingService messagingService) : base(context, mapper)
        {
            _messagingService = messagingService;
        }

        public override async Task BeforeInsert(Database.OrderItems entity, OrderItemsInsertRequest insert)
        {
           
            
            var orderExists = await _context.Orders.AnyAsync(o => o.OrderId == insert.OrderId);
            if (!orderExists)
            {
                
                throw new InvalidOperationException($"Order with ID {insert.OrderId} does not exist.");
            }
        

            
            var productExists = await _context.Products.AnyAsync(p => p.Id == insert.ProductId);
            if (!productExists)
            {
                
                throw new InvalidOperationException($"Product with ID {insert.ProductId} does not exist.");
            }
            

            
            entity.Quantity = insert.Quantity > 0 ? insert.Quantity : insert.Amount;
            
            
            entity.Price = insert.Price;

            
        }

        public override async Task AfterInsert(Database.OrderItems entity, OrderItemsInsertRequest insert)
        {
            
            await UpdateOrderTotalPrice(entity.OrderId);
            
            
            var orderItemCount = await _context.OrderItems
                .Where(oi => oi.OrderId == entity.OrderId)
                .CountAsync();
                
            if (orderItemCount == 1) 
            {
                
                await TriggerOrderCreatedMessage(entity.OrderId);
            }
        }

        public override async Task AfterUpdate(Database.OrderItems entity, OrderItemsUpdateRequest update)
        {
            
            await UpdateOrderTotalPrice(entity.OrderId);
        }

        public async Task<List<Model.OrderItems>> GetOrderItemsByOrderIdAsync(int orderId)
        {
            var orderItems = await _context.OrderItems
                .Where(oi => oi.OrderId == orderId)
                .ToListAsync();

            return _mapper.Map<List<Model.OrderItems>>(orderItems);
        }

        
        private async Task UpdateOrderTotalPrice(int orderId)
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

        
        private async Task TriggerOrderCreatedMessage(int orderId)
        {
            try
            {
                
                
                var order = await _context.Orders
                    .Include(o => o.OrderItems)
                    .Include(o => o.User)
                    .FirstOrDefaultAsync(o => o.OrderId == orderId);
                
                if (order == null)
                {
                    
                    return;
                }

                
                
                var message = new OrderCreatedMessage
                {
                    OrderId = order.OrderId,
                    OrderNumber = order.OrderNumber,
                    UserId = order.UserId,
                    UserName = $"{order.User?.Name} {order.User?.Surname}".Trim(),
                    UserEmail = order.User?.Email,
                    TotalPrice = order.TotalPrice,
                    OrderDate = order.OrderDate,
                    OrderItems = order.OrderItems.Select(oi => new OrderItemMessage
                    {
                        ProductId = oi.ProductId,
                        ProductName = "", 
                        Quantity = oi.Quantity,
                        Price = oi.Price
                    }).ToList()
                };

                
                
                await _messagingService.PublishOrderCreatedAsync(message);
                
                
            }
            catch (Exception ex)
            {
                
                Console.WriteLine($"Error triggering order created message: {ex.Message}");
            }
        }
    }
}
