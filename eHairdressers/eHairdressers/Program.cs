using eHairdressers;
using eHairdressers.Auth;
using eHairdressers.Filters;
using eHairdressers.Json;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using eHairdressers.Services.Database;
using EasyNetQ;

using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = null;
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.MaxDepth = 32;
        options.JsonSerializerOptions.Converters.Add(new UtcDateTimeConverter());
        options.JsonSerializerOptions.Converters.Add(new UtcNullableDateTimeConverter());
    });

builder.Services.AddSignalR();

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.SetIsOriginAllowed(origin => true)
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme()
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "JWT token obtained from POST /User/login. Swagger adds the 'Bearer ' prefix automatically - just paste the raw token."
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer"}
            },
            new string[]{}
        }
    });

    c.DocInclusionPredicate((name, api) => true);
    });
builder.Services.AddTransient<IProductsService, ProductsService>();
builder.Services.AddTransient<IService<eHairdressers.Model.Brand,BaseSearchObject>, BaseService<eHairdressers.Model.Brand,eHairdressers.Services.Database.Brand,BaseSearchObject>>();
builder.Services.AddTransient<IUserService, UserService>();

builder.Services.AddTransient<IService<eHairdressers.Model.Service, BaseSearchObject>, BaseService<eHairdressers.Model.Service, eHairdressers.Services.Database.Service, BaseSearchObject>>();
builder.Services.AddTransient<IService<eHairdressers.Model.Category, BaseSearchObject>, BaseService<eHairdressers.Model.Category, eHairdressers.Services.Database.Category, BaseSearchObject>>();
builder.Services.AddTransient<IAppointmentService, AppointmentService>();
builder.Services.AddTransient<IOrdersService, OrdersService>();
builder.Services.AddTransient<IOrderItemsService, OrderItemsService>();
builder.Services.AddTransient<IPaymentService, PaymentService>();
builder.Services.AddHttpContextAccessor();

builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<IChatRoomService, ChatRoomService>();
builder.Services.AddHostedService<eHairdressers.Services.ChatRoomCleanupService>();
builder.Services.AddTransient<IMessageService, MessageService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<IProductSalesReportService, ProductSalesReportService>();
builder.Services.AddTransient<ISalonOperationsReportService, SalonOperationsReportService>();
builder.Services.AddTransient<IUserAccountService, UserAccountService>();
builder.Services.AddTransient<IUserRoleService, UserRoleService>();
builder.Services.AddTransient<IRecommendationService, RecommendationService>();

var rabbitMqSection = builder.Configuration.GetSection("RabbitMQ");
var rabbitMqHost = rabbitMqSection["Host"];
var rabbitMqPort = rabbitMqSection["Port"];
var rabbitMqVirtualHost = rabbitMqSection["VirtualHost"];
var rabbitMqUsername = rabbitMqSection["Username"];
var rabbitMqPassword = rabbitMqSection["Password"];
var rabbitMqConnectionString =
    $"host={rabbitMqHost};port={rabbitMqPort};virtualHost={rabbitMqVirtualHost};username={rabbitMqUsername};password={rabbitMqPassword}";

builder.Services.AddEasyNetQ(rabbitMqConnectionString);

builder.Services.AddTransient<IMessagingService, MessagingService>();
builder.Services.AddTransient<IEmployeeService, EmployeeService>();

builder.Services.AddAutoMapper(cfg => { }, typeof(IProductsService));

var jwtSection = builder.Configuration.GetSection(JwtOptions.SectionName);
builder.Services.Configure<JwtOptions>(jwtSection);
var jwtOptions = jwtSection.Get<JwtOptions>() ?? new JwtOptions();

if (string.IsNullOrWhiteSpace(jwtOptions.Key))
{
    throw new InvalidOperationException(
        "Jwt:Key is not configured. Set JWT_SECRET_KEY in your .env file (docker) or as a Jwt:Key user-secret / environment variable for local runs.");
}

builder.Services.AddScoped<IJwtTokenService, JwtTokenService>();
builder.Services.AddScoped<IRevokedTokenService, RevokedTokenService>();

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidIssuer = jwtOptions.Issuer,
            ValidateAudience = true,
            ValidAudience = jwtOptions.Audience,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtOptions.Key)),
            ValidateLifetime = true,
            ClockSkew = TimeSpan.FromMinutes(1)
        };

        options.Events = new JwtBearerEvents
        {
            OnTokenValidated = async context =>
            {
                var jti = context.Principal?.FindFirstValue(JwtRegisteredClaimNames.Jti);
                if (!string.IsNullOrEmpty(jti))
                {
                    try
                    {
                        var revokedTokenService = context.HttpContext.RequestServices.GetRequiredService<IRevokedTokenService>();
                        if (await revokedTokenService.IsRevokedAsync(jti))
                        {
                            context.Fail("This token has been revoked (user logged out).");
                        }
                    }
                    catch (Exception ex)
                    {

                        var logger = context.HttpContext.RequestServices.GetRequiredService<ILogger<Program>>();
                        logger.LogError(ex, "Revoked-token check failed for jti {Jti}; allowing request through.", jti);
                    }
                }
            }
        };
    });

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<eHairdressersContext>(options =>
    options.UseSqlServer(connectionString));

void LoadDockerSecretIntoConfig(string secretFilePath, string configKey)
{
    if (File.Exists(secretFilePath))
    {
        var value = File.ReadAllText(secretFilePath).Trim();
        if (!string.IsNullOrEmpty(value))
        {
            builder.Configuration[configKey] = value;
        }
    }
}

LoadDockerSecretIntoConfig("/run/secrets/stripe_secret_key", "Stripe:SecretKey");
LoadDockerSecretIntoConfig("/run/secrets/stripe_webhook_secret", "Stripe:WebhookSecret");

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<eHairdressersContext>();
    var startupLogger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
    try
    {
        const int maxAttempts = 5;
        for (int attempt = 1; attempt <= maxAttempts; attempt++)
        {
            try
            {
                dataContext.Database.Migrate();
                break;
            }
            catch (Exception ex) when (attempt < maxAttempts)
            {
                startupLogger.LogWarning(ex, "Database migration attempt {Attempt}/{MaxAttempts} failed, retrying in 5s...", attempt, maxAttempts);
                await Task.Delay(TimeSpan.FromSeconds(5));
            }
        }

        await dataContext.Database.ExecuteSqlRawAsync(@"
            IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'RevokedTokens')
            BEGIN
                CREATE TABLE [RevokedTokens] (
                    [RevokedTokenId] int NOT NULL IDENTITY(1,1),
                    [Jti] nvarchar(450) NOT NULL,
                    [ExpiresAtUtc] datetime2 NOT NULL,
                    [RevokedAtUtc] datetime2 NOT NULL,
                    CONSTRAINT [PK_RevokedTokens] PRIMARY KEY ([RevokedTokenId])
                );
                CREATE UNIQUE INDEX [IX_RevokedTokens_Jti] ON [RevokedTokens] ([Jti]);
            END");

        await eHairdressers.Services.Database.SeedData.SeedAllData(dataContext);
    }
    catch (Exception ex)
    {
        var logger = scope.ServiceProvider.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "An error occurred while seeding the database. Application will continue without seed data.");

    }
}

app.UseSwagger();
app.UseSwaggerUI();

if (app.Environment.IsProduction())
{
    app.UseHttpsRedirection();
}

app.UseStaticFiles();

app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.MapHub<eHairdressers.Hubs.ChatHub>("/chatHub");

app.Run();
