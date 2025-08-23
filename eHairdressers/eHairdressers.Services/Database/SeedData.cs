using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Services.Database
{
    public static class SeedData
    {
        public static async Task SeedAllData(eHairdressersContext context)
        {
            await SeedRoles(context);
            await SeedCategories(context);
            await SeedBrands(context);
            await SeedServices(context);
            await SeedUsers(context);
            await SeedEmployees(context);
            await SeedProducts(context);
            await SeedSampleAppointments(context);
            await SeedSampleOrders(context);
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
                new Category { Name = "kerastase" }
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

            var users = new List<User>
            {
                new User { Name = "amila", Surname = "heric", Username = "amila", Email = "amila@to.com", CitizenshipNumber = "123456789", Phone = "+1234567890", BirthDate = "1990-01-01", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "emina", Surname = "heric", Username = "emina", Email = "emina@to.com", CitizenshipNumber = "987654321", Phone = "+0987654321", BirthDate = "1992-05-15", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "ermina", Surname = "music", Username = "ermina", Email = "ermina@hotmail.com", CitizenshipNumber = "456789123", Phone = "+4567891230", BirthDate = "1988-12-10", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "esma", Surname = "gudic", Username = "esma", Email = "esma@hotmail.com", CitizenshipNumber = "789123456", Phone = "+7891234560", BirthDate = "1995-03-20", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "arza", Surname = "malkic", Username = "arza", Email = "arza@example.com", CitizenshipNumber = "321654987", Phone = "+3216549870", BirthDate = "1985-07-08", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "John", Surname = "Doe", Username = "johndoe", Email = "john@example.com", CitizenshipNumber = "111111111", Phone = "+1111111111", BirthDate = "1990-01-01", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "Jane", Surname = "Smith", Username = "janesmith", Email = "jane@example.com", CitizenshipNumber = "222222222", Phone = "+2222222222", BirthDate = "1992-05-15", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "Mike", Surname = "Johnson", Username = "mikejohnson", Email = "mike@example.com", CitizenshipNumber = "333333333", Phone = "+3333333333", BirthDate = "1988-12-10", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "Sarah", Surname = "Williams", Username = "sarahwilliams", Email = "sarah@example.com", CitizenshipNumber = "444444444", Phone = "+4444444444", BirthDate = "1995-03-20", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "David", Surname = "Brown", Username = "davidbrown", Email = "david@example.com", CitizenshipNumber = "555555555", Phone = "+5555555555", BirthDate = "1985-07-08", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "Emily", Surname = "Davis", Username = "emilydavis", Email = "emily@example.com", CitizenshipNumber = "666666666", Phone = "+6666666666", BirthDate = "1993-09-12", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "Chris", Surname = "Wilson", Username = "chriswilson", Email = "chris@example.com", CitizenshipNumber = "777777777", Phone = "+7777777777", BirthDate = "1987-11-25", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "Anna", Surname = "Taylor", Username = "annataylor", Email = "anna@example.com", CitizenshipNumber = "888888888", Phone = "+8888888888", BirthDate = "1991-04-18", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "Tom", Surname = "Anderson", Username = "tomanderson", Email = "tom@example.com", CitizenshipNumber = "999999999", Phone = "+9999999999", BirthDate = "1989-06-30", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "Lisa", Surname = "Thomas", Username = "lisathomas", Email = "lisa@example.com", CitizenshipNumber = "101010101", Phone = "+1010101010", BirthDate = "1994-02-14", PasswordHash = "hashed_password", PasswordSalt = "salt" },
                new User { Name = "Mark", Surname = "Jackson", Username = "markjackson", Email = "mark@example.com", CitizenshipNumber = "121212121", Phone = "+1212121212", BirthDate = "1986-08-22", PasswordHash = "hashed_password", PasswordSalt = "salt" }
            };

            context.User.AddRange(users);
            await context.SaveChangesAsync();

            // Assign default roles
            foreach (var user in users)
            {
                await AssignDefaultRoleToUser(context, user.UserId, "Customer");
            }
        }

        public static async Task SeedEmployees(eHairdressersContext context)
        {
            if (await context.Employees.AnyAsync())
                return;

            var employees = new List<Employees>
            {
                new Employees { Name = "emina", Surname = "heric", CitizenshipNumber = "123456", Phone = "123222222", HireDate = new DateTime(2020, 1, 15), BirthDate = "1990-01-01", Address = "Sarajevo, BiH", Salary = 1500 },
                new Employees { Name = "ajlin", Surname = "turk", CitizenshipNumber = "123569874", Phone = "123222111111", HireDate = new DateTime(2021, 3, 10), BirthDate = "1992-05-15", Address = "Sarajevo, BiH", Salary = 1400 },
                new Employees { Name = "arza", Surname = "cehaja", CitizenshipNumber = "2222211111", Phone = "+3872645879", HireDate = new DateTime(2020, 6, 1), BirthDate = "1988-12-10", Address = "Sarajevo, BiH", Salary = 1600 },
                new Employees { Name = "esma", Surname = "gudic", CitizenshipNumber = "11111111111111111", Phone = "+38761019236", HireDate = new DateTime(2021, 9, 15), BirthDate = "1995-03-20", Address = "Sarajevo, BiH", Salary = 1350 },
                new Employees { Name = "hana", Surname = "malkic", CitizenshipNumber = "444444444444444444", Phone = "+38762589997", HireDate = new DateTime(2022, 1, 20), BirthDate = "1993-09-12", Address = "Sarajevo, BiH", Salary = 1300 },
                new Employees { Name = "ermina", Surname = "music", CitizenshipNumber = "44444444444444444444", Phone = "1236547894", HireDate = new DateTime(2021, 7, 8), BirthDate = "1987-11-25", Address = "Sarajevo, BiH", Salary = 1450 },
                new Employees { Name = "esma", Surname = "gudic", CitizenshipNumber = "1111111111111111111", Phone = "45666699887", HireDate = new DateTime(2022, 3, 12), BirthDate = "1991-04-18", Address = "Sarajevo, BiH", Salary = 1400 },
                new Employees { Name = "arza", Surname = "malkic", CitizenshipNumber = "111223333", Phone = "123456987", HireDate = new DateTime(2020, 11, 5), BirthDate = "1989-06-30", Address = "Sarajevo, BiH", Salary = 1550 },
                new Employees { Name = "ana", Surname = "anic", CitizenshipNumber = "111111111", Phone = "12355566699", HireDate = new DateTime(2021, 5, 18), BirthDate = "1994-02-14", Address = "Sarajevo, BiH", Salary = 1350 },
                new Employees { Name = "kan", Surname = "kano", CitizenshipNumber = "7777777777", Phone = "7896541235", HireDate = new DateTime(2022, 8, 22), BirthDate = "1986-08-22", Address = "Sarajevo, BiH", Salary = 1500 },
                new Employees { Name = "Emma", Surname = "Wilson", CitizenshipNumber = "EMP001", Phone = "+1111111111", HireDate = new DateTime(2020, 1, 15), BirthDate = "1990-01-01", Address = "Sarajevo, BiH", Salary = 1600 },
                new Employees { Name = "Alex", Surname = "Davis", CitizenshipNumber = "EMP002", Phone = "+2222222222", HireDate = new DateTime(2021, 3, 10), BirthDate = "1992-05-15", Address = "Sarajevo, BiH", Salary = 1400 },
                new Employees { Name = "Lisa", Surname = "Miller", CitizenshipNumber = "EMP003", Phone = "+3333333333", HireDate = new DateTime(2022, 6, 1), BirthDate = "1988-12-10", Address = "Sarajevo, BiH", Salary = 1350 },
                new Employees { Name = "Michael", Surname = "Johnson", CitizenshipNumber = "EMP004", Phone = "+4444444444", HireDate = new DateTime(2021, 8, 12), BirthDate = "1995-03-20", Address = "Sarajevo, BiH", Salary = 1550 },
                new Employees { Name = "Sophie", Surname = "Brown", CitizenshipNumber = "EMP005", Phone = "+5555555555", HireDate = new DateTime(2022, 2, 28), BirthDate = "1985-07-08", Address = "Sarajevo, BiH", Salary = 1450 },
                new Employees { Name = "Daniel", Surname = "Taylor", CitizenshipNumber = "EMP006", Phone = "+6666666666", HireDate = new DateTime(2020, 12, 10), BirthDate = "1993-09-12", Address = "Sarajevo, BiH", Salary = 1500 }
            };

            context.Employees.AddRange(employees);
            await context.SaveChangesAsync();
        }

        public static async Task SeedProducts(eHairdressersContext context)
        {
            if (await context.Products.AnyAsync())
                return;

            var category = await context.Category.FirstAsync();
            var brand = await context.Brand.FirstAsync();

            var products = new List<Products>
            {
                new Products { Name = "serum", Description = "serum za vrhove", Code = "s33", Price = 100.0, CategoryId = category.Id, BrandId = brand.Id },
                new Products { Name = "sampon", Description = "sampon za suhu kosu", Code = "sh11", Price = 80.0, CategoryId = category.Id, BrandId = brand.Id },
                new Products { Name = "Ulje za kosu", Description = "ulje za suhu kosu", Code = "u1222", Price = 100.0, CategoryId = category.Id, BrandId = brand.Id },
                new Products { Name = "regenerator", Description = "regenerator", Code = "r121", Price = 50.0, CategoryId = category.Id, BrandId = brand.Id },
                new Products { Name = "kupka", Description = "kupka", Code = "k122", Price = 85.0, CategoryId = category.Id, BrandId = brand.Id },
                new Products { Name = "Professional Shampoo", Description = "High-quality shampoo for all hair types", Code = "SH001", Price = 15.99, CategoryId = category.Id, BrandId = brand.Id },
                new Products { Name = "Conditioner", Description = "Nourishing conditioner for smooth hair", Code = "CO001", Price = 12.99, CategoryId = category.Id, BrandId = brand.Id },
                new Products { Name = "Hair Gel", Description = "Strong hold gel for styling", Code = "HG001", Price = 8.99, CategoryId = category.Id, BrandId = brand.Id },
                new Products { Name = "Hair Spray", Description = "Flexible hold hair spray", Code = "HS001", Price = 9.99, CategoryId = category.Id, BrandId = brand.Id }
            };

            context.Products.AddRange(products);
            await context.SaveChangesAsync();
        }

        public static async Task SeedSampleAppointments(eHairdressersContext context)
        {
            if (await context.Appointments.AnyAsync())
                return;

            var users = await context.User.Take(3).ToListAsync();
            var employees = await context.Employees.Take(5).ToListAsync();
            var service = await context.Services.FirstAsync();

            var appointments = new List<Appointment>
            {
                new Appointment { UserId = users[0].UserId, EmployeeId = employees[0].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = new DateTime(2025, 7, 22), AppointmentTime = new TimeSpan(9, 0, 0), Approved = null, Comment = "First time visit" },
                new Appointment { UserId = users[0].UserId, EmployeeId = employees[0].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = new DateTime(2025, 8, 8), AppointmentTime = new TimeSpan(9, 0, 0), Approved = null, Comment = "Regular customer" },
                new Appointment { UserId = users[0].UserId, EmployeeId = employees[0].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = new DateTime(2025, 8, 8), AppointmentTime = new TimeSpan(10, 0, 0), Approved = false, Comment = "Follow-up appointment" },
                new Appointment { UserId = users[0].UserId, EmployeeId = employees[0].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = new DateTime(2025, 8, 17), AppointmentTime = new TimeSpan(16, 0, 0), Approved = false, Comment = "Evening appointment" },
                new Appointment { UserId = users[0].UserId, EmployeeId = employees[9].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = new DateTime(2025, 8, 20), AppointmentTime = new TimeSpan(12, 0, 0), Approved = false, Comment = "Lunch time appointment" },
                new Appointment { UserId = users[1].UserId, EmployeeId = employees[1].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = DateTime.Today.AddDays(1), AppointmentTime = new TimeSpan(14, 0, 0), Approved = null, Comment = "New customer" },
                new Appointment { UserId = users[2].UserId, EmployeeId = employees[2].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = DateTime.Today.AddDays(2), AppointmentTime = new TimeSpan(16, 0, 0), Approved = null, Comment = "Special occasion" },
                new Appointment { UserId = users[3].UserId, EmployeeId = employees[3].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = DateTime.Today.AddDays(3), AppointmentTime = new TimeSpan(11, 0, 0), Approved = null, Comment = "Regular customer" },
                new Appointment { UserId = users[4].UserId, EmployeeId = employees[4].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = DateTime.Today.AddDays(4), AppointmentTime = new TimeSpan(15, 0, 0), Approved = null, Comment = "First time visit" },
                new Appointment { UserId = users[5].UserId, EmployeeId = employees[5].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = DateTime.Today.AddDays(5), AppointmentTime = new TimeSpan(13, 0, 0), Approved = null, Comment = "Follow-up appointment" },
                new Appointment { UserId = users[6].UserId, EmployeeId = employees[6].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = DateTime.Today.AddDays(6), AppointmentTime = new TimeSpan(17, 0, 0), Approved = null, Comment = "Evening appointment" },
                new Appointment { UserId = users[7].UserId, EmployeeId = employees[7].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = DateTime.Today.AddDays(7), AppointmentTime = new TimeSpan(10, 0, 0), Approved = null, Comment = "Morning appointment" },
                new Appointment { UserId = users[8].UserId, EmployeeId = employees[8].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = DateTime.Today.AddDays(8), AppointmentTime = new TimeSpan(14, 0, 0), Approved = null, Comment = "Regular customer" },
                new Appointment { UserId = users[9].UserId, EmployeeId = employees[9].EmployeeId, ServiceId = service.ServiceId, AppointmentDate = DateTime.Today.AddDays(9), AppointmentTime = new TimeSpan(16, 0, 0), Approved = null, Comment = "Special occasion" }
            };

            context.Appointments.AddRange(appointments);
            await context.SaveChangesAsync();
        }

        public static async Task SeedSampleOrders(eHairdressersContext context)
        {
            var users = await context.User.Take(5).ToListAsync();
            var products = await context.Products.Take(5).ToListAsync();
            var existingOrders = await context.Orders.ToListAsync(); // Get ALL orders

            if (!existingOrders.Any())
            {
                // Create new orders if none exist
                var orders = new List<Orders>
                {
                    new Orders { UserId = users[0].UserId, OrderNumber = "ORD-638906214062208122", TotalPrice = 280.0, OrderDate = new DateTime(2025, 8, 12, 18, 50, 6), Status = false },
                    new Orders { UserId = users[0].UserId, OrderNumber = "ORD-638906215839713142", TotalPrice = 165.0, OrderDate = new DateTime(2025, 8, 12, 18, 53, 3), Status = false },
                    new Orders { UserId = users[0].UserId, OrderNumber = "ORD-638906215888176321", TotalPrice = 200.0, OrderDate = new DateTime(2025, 8, 12, 18, 53, 8), Status = false },
                    new Orders { UserId = users[1].UserId, OrderNumber = "ORD-638906216061176562", TotalPrice = 150.0, OrderDate = new DateTime(2025, 8, 12, 18, 53, 26), Status = false },
                    new Orders { UserId = users[1].UserId, OrderNumber = "ORD-638906216232123218", TotalPrice = 320.0, OrderDate = new DateTime(2025, 8, 12, 18, 53, 43), Status = false },
                    new Orders { UserId = users[2].UserId, OrderNumber = "ORD-638906216400123456", TotalPrice = 180.0, OrderDate = new DateTime(2025, 8, 12, 19, 0, 0), Status = false },
                    new Orders { UserId = users[2].UserId, OrderNumber = "ORD-638906216500654321", TotalPrice = 95.0, OrderDate = new DateTime(2025, 8, 12, 19, 10, 0), Status = false },
                    new Orders { UserId = users[3].UserId, OrderNumber = "ORD-638906216600789123", TotalPrice = 250.0, OrderDate = new DateTime(2025, 8, 12, 19, 20, 0), Status = false },
                    new Orders { UserId = users[3].UserId, OrderNumber = "ORD-638906216700456789", TotalPrice = 175.0, OrderDate = new DateTime(2025, 8, 12, 19, 30, 0), Status = false },
                    new Orders { UserId = users[4].UserId, OrderNumber = "ORD-638906216800987654", TotalPrice = 300.0, OrderDate = new DateTime(2025, 8, 12, 19, 40, 0), Status = false }
                };

                context.Orders.AddRange(orders);
                await context.SaveChangesAsync();
                existingOrders = orders;
            }

            // Check which orders already have items
            var ordersWithItems = await context.OrderItems
                .Select(oi => oi.OrderId)
                .Distinct()
                .ToListAsync();

            var ordersNeedingItems = existingOrders
                .Where(o => !ordersWithItems.Contains(o.OrderId))
                .ToList();

            Console.WriteLine($"Total orders: {existingOrders.Count}");
            Console.WriteLine($"Orders with items: {ordersWithItems.Count}");
            Console.WriteLine($"Orders needing items: {ordersNeedingItems.Count}");

            if (!ordersNeedingItems.Any())
                return; // All orders already have items

            // Add order items to orders that don't have them
            var orderItems = new List<OrderItems>();
            var productIndex = 0;

            foreach (var order in ordersNeedingItems)
            {
                Console.WriteLine($"Processing order {order.OrderId} with total price {order.TotalPrice}");
                
                // For orders with existing total prices, try to recreate realistic order items
                if (order.TotalPrice > 0)
                {
                    // Try to create order items that sum up to the existing total price
                    var remainingTotal = order.TotalPrice;
                    var itemsCreated = 0;
                    
                    while (remainingTotal > 0 && itemsCreated < 3)
                    {
                        var product = products[productIndex % products.Count];
                        var maxQuantity = Math.Min(3, (int)(remainingTotal / product.Price));
                        
                        if (maxQuantity > 0)
                        {
                            var quantity = Math.Min(maxQuantity, new Random().Next(1, maxQuantity + 1));
                            var price = product.Price * quantity;
                            
                            orderItems.Add(new OrderItems 
                            { 
                                OrderId = order.OrderId, 
                                ProductId = product.Id, 
                                Quantity = quantity, 
                                Price = price 
                            });
                            
                            remainingTotal -= price;
                            itemsCreated++;
                        }
                        else
                        {
                            // If product price is too high, just add 1 item
                            orderItems.Add(new OrderItems 
                            { 
                                OrderId = order.OrderId, 
                                ProductId = product.Id, 
                                Quantity = 1, 
                                Price = product.Price 
                            });
                            remainingTotal -= product.Price;
                            itemsCreated++;
                        }
                        
                        productIndex++;
                    }
                }
                else
                {
                    // For orders with 0 total price, add random items
                    var itemCount = new Random().Next(1, 4);
                    for (int i = 0; i < itemCount; i++)
                    {
                        var product = products[productIndex % products.Count];
                        var quantity = new Random().Next(1, 4);
                        var price = product.Price * quantity;

                        orderItems.Add(new OrderItems 
                        { 
                            OrderId = order.OrderId, 
                            ProductId = product.Id, 
                            Quantity = quantity, 
                            Price = price 
                        });

                        productIndex++;
                    }
                }
            }

            Console.WriteLine($"Created {orderItems.Count} order items");

            if (orderItems.Any())
            {
                context.OrderItems.AddRange(orderItems);
                await context.SaveChangesAsync();

                // Update order total prices for orders that just got items
                foreach (var order in ordersNeedingItems)
                {
                    var totalPrice = orderItems
                        .Where(oi => oi.OrderId == order.OrderId)
                        .Sum(oi => oi.Price);
                    
                    order.TotalPrice = totalPrice;
                }
                
                await context.SaveChangesAsync();
                Console.WriteLine("Successfully saved order items and updated total prices");
            }
        }

        public static async Task AssignDefaultRoleToUser(eHairdressersContext context, int userId, string roleName = "Customer")
        {
            var existingRoles = await context.UserRole
                .Where(ur => ur.UserId == userId)
                .AnyAsync();

            if (existingRoles)
                return;

            var role = await context.Role.FirstOrDefaultAsync(r => r.Name == roleName);
            if (role == null)
                return;

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


