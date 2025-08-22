using eHairdressers.Model.Messages;

namespace eHairdressers.Services
{
    public interface IMessagingService
    {
        Task PublishOrderCreatedAsync(OrderCreatedMessage message);
        Task PublishAppointmentCreatedAsync(AppointmentCreatedMessage message);
        Task<bool> IsConnectedAsync();
    }
}
