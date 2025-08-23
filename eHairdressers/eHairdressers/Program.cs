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
        options.JsonSerializerOptions.PropertyNamingPolicy = null; // Use PascalCase (default)
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
        Scheme = "basic"
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

builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<IChatRoomService, ChatRoomService>();
builder.Services.AddTransient<IMessageService, MessageService>();
builder.Services.AddTransient<INotificationService, NotificationService>();
builder.Services.AddTransient<IProductSalesReportService, ProductSalesReportService>();
builder.Services.AddTransient<ISalonOperationsReportService, SalonOperationsReportService>();
builder.Services.AddTransient<IUserAccountService, UserAccountService>();
builder.Services.AddTransient<IUserRoleService, UserRoleService>();
builder.Services.AddTransient<IRecommendationService, RecommendationService>();


// Configure EasyNetQ for RabbitMQ messaging
builder.Services.AddSingleton<IBus>(provider =>
{
    var connectionString = "host=localhost;port=5672;virtualHost=/;username=guest;password=guest";
    var bus = RabbitHutch.CreateBus(connectionString);
    
    // Ensure the bus is properly disposed when the application shuts down
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

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<eHairdressersContext>();
    dataContext.Database.Migrate();
    
    // Seed comprehensive data for development
    await eHairdressers.Services.Database.SeedData.SeedAllData(dataContext);
}
// Configure the HTTP request pipeline.
// Enable Swagger in all environments for API documentation
app.UseSwagger();
app.UseSwaggerUI();

// Only use HTTPS redirection in Production to avoid SSL issues in Development
if (app.Environment.IsProduction())
{
    app.UseHttpsRedirection();
}

app.UseStaticFiles();

// Use CORS
app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Map SignalR Hub
app.MapHub<eHairdressers.Hubs.ChatHub>("/chatHub");

app.Run();
