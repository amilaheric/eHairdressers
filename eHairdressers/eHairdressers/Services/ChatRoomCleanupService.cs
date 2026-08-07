using eHairdressers.Services;

namespace eHairdressers.Services
{
 
    public class ChatRoomCleanupService : BackgroundService
    {
        private readonly IServiceScopeFactory _scopeFactory;
        private readonly ILogger<ChatRoomCleanupService> _logger;
        private readonly IConfiguration _configuration;

        private static readonly TimeSpan CheckInterval = TimeSpan.FromHours(24);

        public ChatRoomCleanupService(
            IServiceScopeFactory scopeFactory,
            ILogger<ChatRoomCleanupService> logger,
            IConfiguration configuration)
        {
            _scopeFactory = scopeFactory;
            _logger = logger;
            _configuration = configuration;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    var retentionDays = _configuration.GetValue<int?>("Chat:RoomRetentionDays") ?? 7;

                    using var scope = _scopeFactory.CreateScope();
                    var chatRoomService = scope.ServiceProvider.GetRequiredService<IChatRoomService>();

                    var deactivatedCount = await chatRoomService.DeactivateInactiveChatRooms(retentionDays);

                    if (deactivatedCount > 0)
                    {
                        _logger.LogInformation(
                            "Chat room cleanup: deactivated {Count} chat room(s) inactive for more than {RetentionDays} day(s).",
                            deactivatedCount, retentionDays);
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Chat room cleanup job failed.");
                }

                await Task.Delay(CheckInterval, stoppingToken);
            }
        }
    }
}
