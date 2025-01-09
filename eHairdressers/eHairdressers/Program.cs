using eHairdressers;
using eHairdressers.Filters;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using eHairdressers.Services.Database;
using eHairdressers.Services.ProductsStateMachine;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
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
builder.Services.AddTransient<BaseState>();
builder.Services.AddTransient<InitialState>();
builder.Services.AddTransient<DraftProductState>();
builder.Services.AddTransient<ActiveProductState>();


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
    //dataContext.Database.Migrate();
}
// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
