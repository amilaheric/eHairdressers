using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.Database
{
    public class eHairdressersContext: DbContext
    {

        public eHairdressersContext(DbContextOptions options)
        : base(options)
        {
        }

        public DbSet<Products> Products { get; set; }
        public DbSet<Category> Category { get; set; }
        public DbSet<Brand> Brand { get; set; }
        public DbSet<Role> Role { get; set; }
        public DbSet<User> User { get; set; }
        public DbSet<UserRole> UserRole { get; set; }
        public DbSet<Orders> Orders { get; set; }
        public DbSet<OrderItems> OrderItems { get; set; }
        public DbSet<Cart> Cart { get; set; }
        public DbSet<CartItems> CartItems { get; set; }
        public DbSet<Customers> Customers { get; set; }
        public DbSet<Availability> Availability { get; set; }
        public DbSet<Appointment> Appointments { get; set; }
        public DbSet<Reviews> Reviews { get; set; }
        public DbSet<Service> Services { get; set; }



    }
}
