using eHairdressers.Worker.Configuration;
using eHairdressers.Worker.Consumers;
using eHairdressers.Worker.Services;
using EasyNetQ;

var builder = Host.CreateApplicationBuilder(args);

// Bind SMTP config from appsettings.json / environment variables ("Smtp" section) -
// never hardcoded in source, per project configuration rules.
builder.Services.Configure<SmtpOptions>(builder.Configuration.GetSection("Smtp"));
builder.Services.AddSingleton<IEmailSender, SmtpEmailSender>();

// Build the RabbitMQ connection string from config (appsettings.json "RabbitMQ" section),
// same pattern as the main API - host/port/virtualHost/username/password are all configurable,
// not hardcoded.
var rabbitMqSection = builder.Configuration.GetSection("RabbitMQ");
var rabbitMqHost = rabbitMqSection["Host"];
var rabbitMqPort = rabbitMqSection["Port"];
var rabbitMqVirtualHost = rabbitMqSection["VirtualHost"];
var rabbitMqUsername = rabbitMqSection["Username"];
var rabbitMqPassword = rabbitMqSection["Password"];
var rabbitMqConnectionString =
    $"host={rabbitMqHost};port={rabbitMqPort};virtualHost={rabbitMqVirtualHost};username={rabbitMqUsername};password={rabbitMqPassword}";

builder.Services.AddEasyNetQ(rabbitMqConnectionString);

builder.Services.AddHostedService<RabbitMqConsumerService>();

var host = builder.Build();
host.Run();
