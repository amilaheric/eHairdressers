using eHairdressers.Model.Messages;
using eHairdressers.Worker.Services;
using EasyNetQ;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace eHairdressers.Worker.Consumers
{
    public class RabbitMqConsumerService : BackgroundService
    {
        private readonly IBus _bus;
        private readonly IEmailSender _emailSender;
        private readonly ILogger<RabbitMqConsumerService> _logger;

        public RabbitMqConsumerService(IBus bus, IEmailSender emailSender, ILogger<RabbitMqConsumerService> logger)
        {
            _bus = bus;
            _emailSender = emailSender;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("eHairdressers.Worker starting - subscribing to RabbitMQ topics 'order.created' and 'appointment.created'.");

            await _bus.PubSub.SubscribeAsync<OrderCreatedMessage>(
                "ehairdressers.worker.order-created",
                message => HandleOrderCreatedAsync(message, stoppingToken),
                config => config.WithTopic("order.created"),
                stoppingToken);

            await _bus.PubSub.SubscribeAsync<AppointmentCreatedMessage>(
                "ehairdressers.worker.appointment-created",
                message => HandleAppointmentCreatedAsync(message, stoppingToken),
                config => config.WithTopic("appointment.created"),
                stoppingToken);

            _logger.LogInformation("eHairdressers.Worker subscriptions active. Waiting for messages...");

            try
            {
                await Task.Delay(Timeout.Infinite, stoppingToken);
            }
            catch (TaskCanceledException)
            {
                // Expected on shutdown.
            }
        }

        private async Task HandleOrderCreatedAsync(OrderCreatedMessage message, CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation(
                    "Processing order.created event: OrderId={OrderId}, OrderNumber={OrderNumber}, UserId={UserId}, Total={Total}",
                    message.OrderId, message.OrderNumber, message.UserId, message.TotalPrice);

                var itemsSummary = string.Join(
                    "\n",
                    message.OrderItems.Select(i => $"  - {i.Quantity} x {i.ProductName} ({i.Price:C})"));

                var body =
                    $"Hi {message.UserName},\n\n" +
                    $"Thanks for your order #{message.OrderNumber}!\n\n" +
                    $"Items:\n{itemsSummary}\n\n" +
                    $"Total: {message.TotalPrice:C}\n" +
                    $"Order date: {message.OrderDate:g}\n\n" +
                    "- eHairdressers";

                await _emailSender.SendAsync(
                    message.UserEmail,
                    message.UserName,
                    $"Order confirmation - #{message.OrderNumber}",
                    body,
                    cancellationToken);
            }
            catch (Exception ex)
            {
                // Isolate failures per-message so one bad message doesn't take down the consumer.
                _logger.LogError(ex, "Error processing order.created event for OrderId={OrderId}", message.OrderId);
            }
        }

        private async Task HandleAppointmentCreatedAsync(AppointmentCreatedMessage message, CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation(
                    "Processing appointment.created event: AppointmentId={AppointmentId}, UserId={UserId}, EmployeeId={EmployeeId}, Date={Date} {Time}",
                    message.AppointmentId, message.UserId, message.EmployeeId, message.AppointmentDate, message.AppointmentTime);

                var body =
                    $"Hi {message.UserName},\n\n" +
                    $"Your appointment for '{message.ServiceName}' with {message.EmployeeName} is confirmed.\n\n" +
                    $"Date: {message.AppointmentDate:d}\n" +
                    $"Time: {message.AppointmentTime:hh\\:mm}\n" +
                    (string.IsNullOrWhiteSpace(message.Comment) ? "" : $"Note: {message.Comment}\n") +
                    "\n- eHairdressers";

                await _emailSender.SendAsync(
                    message.UserEmail,
                    message.UserName,
                    "Appointment confirmation",
                    body,
                    cancellationToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error processing appointment.created event for AppointmentId={AppointmentId}", message.AppointmentId);
            }
        }
    }
}
