using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;

namespace eHairdressers.Services.Database
{
    public class eHairdressersContextFactory : IDesignTimeDbContextFactory<eHairdressersContext>
    {
        public eHairdressersContext CreateDbContext(string[] args)
        {
            var optionsBuilder = new DbContextOptionsBuilder<eHairdressersContext>();
            
            // Use the same connection string as in your appsettings.json
            optionsBuilder.UseSqlServer("Data Source=LAPTOP-1P2EANGR\\SQLAMILA;Initial Catalog=eHairdressers; user=sa; Password=user; TrustServerCertificate =True");
            
            return new eHairdressersContext(optionsBuilder.Options);
        }
    }
}
