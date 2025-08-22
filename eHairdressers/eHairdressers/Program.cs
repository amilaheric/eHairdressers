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

// Add services to the container.

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = null; // Use PascalCase (default)
        options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
        options.JsonSerializerOptions.MaxDepth = 32;
    });

// Add SignalR
builder.Services.AddSignalR();

// Add CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.SetIsOriginAllowed(origin => true) // Allow any origin
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
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

// Register messaging service
builder.Services.AddTransient<IMessagingService, MessagingService>();
builder.Services.AddTransient<IEmployeeService, EmployeeService>();






builder.Services.AddAutoMapper(typeof(IProductsService));
//builder.Services.AddControllers(x =>
//{
//    x.Filters.Add<ErrorFilter>();
//});

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
    
    // Seed default roles
    await eHairdressers.Services.Database.SeedData.SeedRoles(dataContext);
}
// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

// Use CORS
app.UseCors("AllowAll");

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Map SignalR Hub
app.MapHub<eHairdressers.Hubs.ChatHub>("/chatHub");

app.Run();
