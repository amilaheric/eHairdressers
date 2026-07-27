using eHairdressers;
using eHairdressers.Filters;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using eHairdressers.Services.Database;
using EasyNetQ;

using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = null; 
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.MaxDepth = 32;
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
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic",
        Description = "Basic Authentication header"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
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
builder.Services.AddTransient<IMessageService, MessageService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<IProductSalesReportService, ProductSalesReportService>();
builder.Services.AddTransient<ISalonOperationsReportService, SalonOperationsReportService>();
builder.Services.AddTransient<IUserAccountService, UserAccountService>();
builder.Services.AddTransient<IUserRoleService, UserRoleService>();
builder.Services.AddTransient<IRecommendationService, RecommendationService>();


builder.Services.AddSingleton<IBus>(provider =>
{
    var connectionString = "host=rabbitmq;port=5672;virtualHost=/;username=admin;password=admin123";
    var bus = RabbitHutch.CreateBus(connectionString);
    
    var lifetime = provider.GetService<IHostApplicationLifetime>();
    if (lifetime != null)
    {
        lifetime.ApplicationStopping.Register(() => bus.Dispose());
    }
    
    return bus;
});


builder.Services.AddTransient<IMessagingService, MessagingService>();
builder.Services.AddTransient<IEmployeeService, EmployeeService>();



builder.Services.AddAutoMapper(typeof(IProductsService));


builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

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
    try
    {
        dataContext.Database.Migrate();

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
