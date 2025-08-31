using Microsoft.EntityFrameworkCore;
using System.IO;

namespace eHairdressers.Services.Database
{
    public static class SeedData
    {
        private static byte[]? LoadImageAsBytes(string imagePath)
        {
            try
            {
              
                
                if (File.Exists(imagePath))
                {
                   
                    var bytes = File.ReadAllBytes(imagePath);
                    
                    return bytes;
                }
                else
                {
                    
                 
                    var alternativePaths = new[]
                    {
                        Path.Combine("wwwroot", "images", "products", "serum2.jpg"),
                        Path.Combine("..", "wwwroot", "images", "products", "serum2.jpg"),
                        Path.Combine("..", "..", "wwwroot", "images", "products", "serum2.jpg"),
                        Path.Combine("/app", "wwwroot", "images", "products", "serum2.jpg")
                    };
                    
                    foreach (var altPath in alternativePaths)
                    {
                       
                        if (File.Exists(altPath))
                        {
                            var bytes = File.ReadAllBytes(altPath);
                        
                            return bytes;
                        }
                    }
                }
                return null;
            }
            catch (Exception ex)
            {
            
                return null;
            }
        }

        public static async Task SeedAllData(eHairdressersContext context)
        {
            try
            {
                await ClearExistingData(context);
         
                await SeedRoles(context);
                
                await SeedCategories(context);
               
                await SeedBrands(context);
              
                await SeedServices(context);
            
                await SeedUsers(context);
        
                await SeedEmployees(context);
        
                await SeedProducts(context);
   
                await SeedSampleAppointments(context);
             
             
                await SeedSampleOrders(context);
            
                
      
                await SeedPayments(context);
             
            }
            catch (Exception ex)
            {
                
                throw; 
            }
        }

        public static async Task ClearExistingData(eHairdressersContext context)
        {
            try
            {
                
                context.UserRole.RemoveRange(await context.UserRole.ToListAsync());
                
                
                context.Employees.RemoveRange(await context.Employees.ToListAsync());
                
                
                context.Appointments.RemoveRange(await context.Appointments.ToListAsync());
                
                
                context.OrderItems.RemoveRange(await context.OrderItems.ToListAsync());
                
                
                context.Orders.RemoveRange(await context.Orders.ToListAsync());
                
                
                context.Payments.RemoveRange(await context.Payments.ToListAsync());
                
                
                context.Products.RemoveRange(await context.Products.ToListAsync());
                
                
                context.Services.RemoveRange(await context.Services.ToListAsync());
                
                
                context.User.RemoveRange(await context.User.ToListAsync());
                
                context.ChatRoomUsers.RemoveRange(await context.ChatRoomUsers.ToListAsync());
                
                context.ChatRooms.RemoveRange(await context.ChatRooms.ToListAsync());
                
                context.Messages.RemoveRange(await context.Messages.ToListAsync());     

                context.Role.RemoveRange(await context.Role.ToListAsync());
                
                
                context.Category.RemoveRange(await context.Category.ToListAsync());
                
                
                context.Brand.RemoveRange(await context.Brand.ToListAsync());
                
                await context.SaveChangesAsync();
               
            }
            catch (Exception ex)
            {
               
                throw;
            }
        }

        public static async Task SeedRoles(eHairdressersContext context)
        {
            if (await context.Role.AnyAsync())
                return;

            var roles = new List<Role>
            {
                new Role { Name = "Customer", Description = "Regular customer" },
                new Role { Name = "Employee", Description = "Salon employee" },
                new Role { Name = "Admin", Description = "System administrator" }
            };

            context.Role.AddRange(roles);
            await context.SaveChangesAsync();
        }

        public static async Task SeedCategories(eHairdressersContext context)
        {
            if (await context.Category.AnyAsync())
                return;

            var categories = new List<Category>
            {
                new Category { Name = "kerastase", Description = "Premium hair care products" }
            };

            context.Category.AddRange(categories);
            await context.SaveChangesAsync();
        }

        public static async Task SeedBrands(eHairdressersContext context)
        {
            if (await context.Brand.AnyAsync())
                return;

            var brands = new List<Brand>
            {
                new Brand { Name = "kerastase" }
            };

            context.Brand.AddRange(brands);
            await context.SaveChangesAsync();
        }

        public static async Task SeedServices(eHairdressersContext context)
        {
            if (await context.Services.AnyAsync())
                return;

            var services = new List<Service>
            {
                new Service { ServiceName = "sisanje", Description = "sisanje", Duration = "1 hour" }
            };

            context.Services.AddRange(services);
            await context.SaveChangesAsync();
        }

        public static async Task SeedUsers(eHairdressersContext context)
        {
            if (await context.User.AnyAsync())
                return;

            var userData = new[]
            {
                new { Name = "amila", Surname = "heric", Username = "amila", Email = "amila@to.com", CitizenshipNumber = "123456789", Phone = "+1234567890", BirthDate = "1990-01-01" },
                new { Name = "emina", Surname = "heric", Username = "emina", Email = "emina@to.com", CitizenshipNumber = "987654321", Phone = "+0987654321", BirthDate = "1992-05-15" },
                new { Name = "ermina", Surname = "music", Username = "ermina", Email = "ermina@hotmail.com", CitizenshipNumber = "456789123", Phone = "+4567891230", BirthDate = "1988-12-10" },
                new { Name = "esma", Surname = "gudic", Username = "esma", Email = "esma@hotmail.com", CitizenshipNumber = "789123456", Phone = "+7891234560", BirthDate = "1995-03-20" },
                new { Name = "arza", Surname = "malkic", Username = "arza", Email = "arza@example.com", CitizenshipNumber = "321654987", Phone = "+3216549870", BirthDate = "1985-07-08" },
                new { Name = "ajlin", Surname = "turk", Username = "ajlin", Email = "ajlin@example.com", CitizenshipNumber = "123569874", Phone = "123222111111", BirthDate = "1992-05-15" },
                new { Name = "hana", Surname = "malkic", Username = "hana", Email = "hana@example.com", CitizenshipNumber = "444444444444444444", Phone = "+38762589997", BirthDate = "1993-09-12" },
                new { Name = "ana", Surname = "anic", Username = "ana", Email = "ana@example.com", CitizenshipNumber = "111111111", Phone = "12355566699", BirthDate = "1994-02-14" },
                new { Name = "kan", Surname = "kano", Username = "kan", Email = "kan@example.com", CitizenshipNumber = "7777777777", Phone = "7896541235", BirthDate = "1986-08-22" }
            };

            var users = new List<User>();
            var defaultPassword = "password123";

            foreach (var userInfo in userData)
            {
                var passwordSalt = eHairdressers.Services.UserService.GenerateSalt();
                var passwordHash = eHairdressers.Services.UserService.GenerateHash(passwordSalt, defaultPassword);

                var user = new User
                {
                    Name = userInfo.Name,
                    Surname = userInfo.Surname,
                    Username = userInfo.Username,
                    Email = userInfo.Email,
                    CitizenshipNumber = userInfo.CitizenshipNumber,
                    Phone = userInfo.Phone,
                    BirthDate = userInfo.BirthDate,
                    PasswordHash = passwordHash,
                    PasswordSalt = passwordSalt
                };

                users.Add(user);
            }

            context.User.AddRange(users);
            await context.SaveChangesAsync();

            
        }

        public static async Task SeedEmployees(eHairdressersContext context)
        {
            if (await context.Employees.AnyAsync())
                return;

            
            var users = await context.User.ToListAsync();
            
            var employees = new List<Employees>
            {
                new Employees { UserId = users.First(u => u.Username == "emina").UserId, Name = "emina", Surname = "heric", CitizenshipNumber = "987654321", Phone = "+0987654321", HireDate = new DateTime(2020, 1, 15), BirthDate = "1990-01-01", Address = "Sarajevo, BiH", Salary = 1500 },
                new Employees { UserId = users.First(u => u.Username == "ermina").UserId, Name = "ermina", Surname = "music", CitizenshipNumber = "456789123", Phone = "+4567891230", HireDate = new DateTime(2021, 7, 8), BirthDate = "1988-12-10", Address = "Sarajevo, BiH", Salary = 1450 }
            };

            context.Employees.AddRange(employees);
            await context.SaveChangesAsync();

            
            await PopulateUserRolesBasedOnEmployees(context);
        }

        public static async Task PopulateUserRolesBasedOnEmployees(eHairdressersContext context)
        {

            var users = await context.User.ToListAsync();
            
            
            var employeeUserIds = await context.Employees
                .Select(e => e.UserId)
                .ToListAsync();

            foreach (var user in users)
            {
                
                if (employeeUserIds.Contains(user.UserId))
                {
                    
                    await AssignDefaultRoleToUser(context, user.UserId, "Employee");
                }
                else
                {
                    
                    await AssignDefaultRoleToUser(context, user.UserId, "Customer");
                }
            }
        }

        public static async Task SeedProducts(eHairdressersContext context)
        {
            if (await context.Products.AnyAsync())
                return;

            var category = await context.Category.FirstAsync();
            var brand = await context.Brand.FirstAsync();

            
            var serumImageBytes = LoadImageAsBytes("wwwroot/images/products/serum2.jpg");
            var samponImageBytes = LoadImageAsBytes("wwwroot/images/products/sampon.webp");
            var uljeImageBytes = LoadImageAsBytes("wwwroot/images/products/ulje.jpg");
            var regeneratorImageBytes = LoadImageAsBytes("wwwroot/images/products/regenerator.jpg");
            var kupkaImageBytes = LoadImageAsBytes("wwwroot/images/products/kupka.jpg");


            if (serumImageBytes != null)
                Console.WriteLine($"Successfully loaded serum image. Size: {serumImageBytes.Length} bytes");
            else
                Console.WriteLine("Failed to load serum image from file");

            if (samponImageBytes != null)
                Console.WriteLine($"Successfully loaded sampon image. Size: {samponImageBytes.Length} bytes");
            else
                Console.WriteLine("Failed to load sampon image from file");

            if (uljeImageBytes != null)
                Console.WriteLine($"Successfully loaded ulje image. Size: {uljeImageBytes.Length} bytes");
            else
                Console.WriteLine("Failed to load ulje image from file");

            if (regeneratorImageBytes != null)
                Console.WriteLine($"Successfully loaded regenerator image. Size: {regeneratorImageBytes.Length} bytes");
            else
                Console.WriteLine("Failed to load regenerator image from file");

            if (kupkaImageBytes != null)
                Console.WriteLine($"Successfully loaded kupka image. Size: {kupkaImageBytes.Length} bytes");
            else
                Console.WriteLine("Failed to load kupka image from file");

            var products = new List<Products>
            {
                new Products { Name = "serum", Description = "serum za vrhove", Code = "s33", Price = 100.0, CategoryId = category.Id, BrandId = brand.Id, Image = serumImageBytes },
                new Products { Name = "sampon", Description = "sampon za suhu kosu", Code = "sh11", Price = 80.0, CategoryId = category.Id, BrandId = brand.Id, Image = samponImageBytes },
                new Products { Name = "Ulje za kosu", Description = "ulje za suhu kosu", Code = "u1222", Price = 100.0, CategoryId = category.Id, BrandId = brand.Id, Image = uljeImageBytes },
                new Products { Name = "regenerator", Description = "regenerator", Code = "r121", Price = 50.0, CategoryId = category.Id, BrandId = brand.Id, Image = regeneratorImageBytes },
                new Products { Name = "kupka", Description = "kupka", Code = "k122", Price = 85.0, CategoryId = category.Id, BrandId = brand.Id, Image = kupkaImageBytes },
            };

            context.Products.AddRange(products);
            await context.SaveChangesAsync();
        }

        public static async Task SeedSampleAppointments(eHairdressersContext context)
        {
            if (await context.Appointments.AnyAsync())
                return;

            var users = await context.User.Take(5).ToListAsync();
            var employees = await context.Employees.Take(5).ToListAsync();
            var service = await context.Services.FirstAsync();

        
            var appointments = new List<Appointment>
            {
                new Appointment { UserId = users[0].UserId, EmployeeId = employees[0].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = new DateTime(2025, 7, 22), AppointmentTime = new TimeSpan(9, 0, 0), Status = "Scheduled", Comment = "First time visit" },
                new Appointment { UserId = users[0].UserId, EmployeeId = employees[0].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = new DateTime(2025, 8, 8), AppointmentTime = new TimeSpan(9, 0, 0), Status = "Scheduled", Comment = "Regular customer" },
                new Appointment { UserId = users[0].UserId, EmployeeId = employees[0].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = new DateTime(2025, 8, 8), AppointmentTime = new TimeSpan(10, 0, 0), Status = "Cancelled", Comment = "Follow-up appointment" },
                new Appointment { UserId = users[0].UserId, EmployeeId = employees[0].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = new DateTime(2025, 8, 17), AppointmentTime = new TimeSpan(16, 0, 0), Status = "Cancelled", Comment = "Evening appointment" },
                new Appointment { UserId = users[0].UserId, EmployeeId = employees[1].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = new DateTime(2025, 8, 20), AppointmentTime = new TimeSpan(12, 0, 0), Status = "Cancelled", Comment = "Lunch time appointment" },
                new Appointment { UserId = users[1].UserId, EmployeeId = employees[1].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = DateTime.Today.AddDays(1), AppointmentTime = new TimeSpan(14, 0, 0), Status = "Scheduled", Comment = "New customer" },
     };

            context.Appointments.AddRange(appointments);
            await context.SaveChangesAsync();
        }

        public static async Task SeedSampleOrders(eHairdressersContext context)
        {
            var users = await context.User.Take(5).ToListAsync();
            var products = await context.Products.Take(8).ToListAsync();
            var existingOrders = await context.Orders.ToListAsync();

            if (!existingOrders.Any())
            {
                
                var orders = new List<Orders>
                {
                    new Orders { UserId = users[0].UserId, OrderNumber = "ORD-001", TotalPrice = 280.0, OrderDate = new DateTime(2025, 8, 15, 14, 30, 0), Status = true },
                    new Orders { UserId = users[0].UserId, OrderNumber = "ORD-002", TotalPrice = 165.0, OrderDate = new DateTime(2025, 8, 16, 16, 45, 0), Status = true },
                    new Orders { UserId = users[1].UserId, OrderNumber = "ORD-003", TotalPrice = 200.0, OrderDate = new DateTime(2025, 8, 17, 11, 15, 0), Status = true },
                    new Orders { UserId = users[1].UserId, OrderNumber = "ORD-004", TotalPrice = 150.0, OrderDate = new DateTime(2025, 8, 25, 13, 20, 0), Status = false },
                    new Orders { UserId = users[2].UserId, OrderNumber = "ORD-005", TotalPrice = 320.0, OrderDate = new DateTime(2025, 8, 31, 15, 10, 0), Status = true },
                    new Orders { UserId = users[2].UserId, OrderNumber = "ORD-006", TotalPrice = 180.0, OrderDate = new DateTime(2025, 8, 22, 10, 30, 0), Status = true },
                    new Orders { UserId = users[3].UserId, OrderNumber = "ORD-007", TotalPrice = 95.0, OrderDate = new DateTime(2025, 8, 21, 17, 45, 0), Status = true },
                    new Orders { UserId = users[3].UserId, OrderNumber = "ORD-008", TotalPrice = 250.0, OrderDate = new DateTime(2025, 8, 20, 12, 0, 0), Status = false },
                    new Orders { UserId = users[4].UserId, OrderNumber = "ORD-009", TotalPrice = 175.0, OrderDate = new DateTime(2025, 8, 23, 14, 15, 0), Status = true },
                    new Orders { UserId = users[0].UserId, OrderNumber = "ORD-010", TotalPrice = 300.0, OrderDate = new DateTime(2025, 8, 25, 16, 30, 0), Status = true }
                };

                context.Orders.AddRange(orders);
                await context.SaveChangesAsync();
                existingOrders = orders;
            }

            
            var ordersWithItems = await context.OrderItems
                .Select(oi => oi.OrderId)
                .Distinct()
                .ToListAsync();

            var ordersNeedingItems = existingOrders
                .Where(o => !ordersWithItems.Contains(o.OrderId))
                .ToList();

            if (!ordersNeedingItems.Any())
                return; 

            
            var orderItems = new List<OrderItems>();
            var random = new Random();

            foreach (var order in ordersNeedingItems)
            {
                
                var itemCount = random.Next(1, 4);
                
                for (int i = 0; i < itemCount; i++)
                {
                    var product = products[i % products.Count];
                    var quantity = random.Next(1, 4);                       
                    var price = product.Price * quantity;
                    
                    orderItems.Add(new OrderItems 
                    { 
                        OrderId = order.OrderId, 
                        ProductId = product.Id, 
                        Quantity = quantity, 
                        Price = price 
                    });
                }
            }

            if (orderItems.Any())
            {
                context.OrderItems.AddRange(orderItems);
                await context.SaveChangesAsync();
            }
        }

        public static async Task SeedPayments(eHairdressersContext context)
        {
            if (await context.Payments.AnyAsync())
                return;

            var orders = await context.Orders.Take(10).ToListAsync();
            if (!orders.Any())
                return;

            var payments = new List<Payment>();
            var paymentMethods = new[] { "Credit Card", "Cash", "Bank Transfer", "PayPal" };
            var paymentStatuses = new[] { "Completed", "Pending", "Failed", "Refunded" };

            foreach (var order in orders)
            {
                var payment = new Payment
                {
                    OrderId = order.OrderId,
                    Amount = (decimal)order.TotalPrice,
                    PaymentDate = order.OrderDate.AddHours(1), 
                    PaymentMethod = paymentMethods[new Random().Next(paymentMethods.Length)],
                    PaymentStatus = paymentStatuses[new Random().Next(paymentStatuses.Length)]
                };

                payments.Add(payment);
            }

            context.Payments.AddRange(payments);
            await context.SaveChangesAsync();
        }

        public static async Task AssignDefaultRoleToUser(eHairdressersContext context, int userId, string roleName = "Customer")
        {
            var role = await context.Role.FirstOrDefaultAsync(r => r.Name == roleName);
            if (role == null)
                return;

            
            var existingUserRole = await context.UserRole
                .FirstOrDefaultAsync(ur => ur.UserId == userId);

            if (existingUserRole != null)
            {
                
                if (existingUserRole.RoleId != role.RoleId)
                {
                    existingUserRole.RoleId = role.RoleId;
                    existingUserRole.DateChange = DateTime.Now;
                    await context.SaveChangesAsync();
                }
            }
            else
            {
                
                var userRole = new UserRole
                {
                    UserId = userId,
                    RoleId = role.RoleId,
                    DateChange = DateTime.Now
                };

                context.UserRole.Add(userRole);
                await context.SaveChangesAsync();
            }
        }
    }
}


