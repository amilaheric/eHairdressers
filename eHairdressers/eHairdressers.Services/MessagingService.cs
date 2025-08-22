using EasyNetQ;
using eHairdressers.Model.Messages;
using Microsoft.Extensions.Logging;

namespace eHairdressers.Services
{
    public class MessagingService : IMessagingService
    {
        private readonly IBus _bus;
        private readonly ILogger<MessagingService> _logger;

        public MessagingService(IBus bus, ILogger<MessagingService> logger)
        {
            _bus = bus;
            _logger = logger;
        }

        public async Task PublishOrderCreatedAsync(OrderCreatedMessage message)
        {
            try
            {
                    
                    await _bus.PubSub.PublishAsync(message, "order.created");
                   
                _logger.LogInformation("Order created message published: OrderId={OrderId}, UserId={UserId}", 
                    message.OrderId, message.UserId);
            }
            catch (ObjectDisposedException ex)
            {
                
                _logger.LogWarning("RabbitMQ connection disposed, cannot publish order message: OrderId={OrderId}", message.OrderId);

            }
            catch (Exception ex)
            {
                
                _logger.LogError(ex, "Error publishing order created message: OrderId={OrderId}", message.OrderId);
                
            }
        }

        public async Task PublishAppointmentCreatedAsync(AppointmentCreatedMessage message)
        {
            try
            {
                
                await _bus.PubSub.PublishAsync(message, "appointment.created");
                
                _logger.LogInformation("Appointment created message published: AppointmentId={AppointmentId}, UserId={UserId}", 
                    message.AppointmentId, message.UserId);
            }
            catch (ObjectDisposedException ex)
            {
                
                _logger.LogWarning("RabbitMQ connection disposed, cannot publish appointment message: AppointmentId={AppointmentId}", message.AppointmentId);
                
            }
            catch (Exception ex)
            {
                
                _logger.LogError(ex, "Error publishing appointment created message: AppointmentId={AppointmentId}", message.AppointmentId);
                
            }
        }

        public async Task<bool> IsConnectedAsync()
        {
            try
            {
                        
                var _ = _bus.PubSub;
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking RabbitMQ connection status");
                return false;
            }
        }
    }
}
