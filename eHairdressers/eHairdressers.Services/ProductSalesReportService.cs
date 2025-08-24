using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Services
{
    public class ProductSalesReportService : IProductSalesReportService
    {
        private readonly eHairdressersContext _context;

        public ProductSalesReportService(eHairdressersContext context)
        {
            _context = context;
        }

        public async Task<List<ProductSalesReport>> GetProductSalesReport(ProductSalesReportRequest request)
        {
            var query = from oi in _context.OrderItems
                       join o in _context.Orders on oi.OrderId equals o.OrderId
                       join p in _context.Products on oi.ProductId equals p.Id
                       where (request.StartDate == DateTime.MinValue || o.OrderDate >= request.StartDate) 
                             && (request.EndDate == DateTime.MinValue || o.OrderDate <= request.EndDate)
                       group new { oi, o, p } by new { p.Id, p.Name, p.Code } into g
                       select new ProductSalesReport
                       {
                           ProductId = g.Key.Id,
                           ProductName = g.Key.Name,
                           ProductCode = g.Key.Code,
                           TotalQuantitySold = g.Sum(x => x.oi.Quantity),
                           TotalRevenue = g.Sum(x => x.oi.Quantity * (decimal)x.oi.Price),
                           SalesFrequency = g.Count(),
                           AveragePrice = g.Average(x => (decimal)x.oi.Price),
                           ReportStartDate = request.StartDate,
                           ReportEndDate = request.EndDate,
                           ReportType = request.ReportType
                       };

            var reports = await query.ToListAsync();

           
            foreach (var report in reports)
            {
                report.DailySales = await GetDailySalesData(report.ProductId, request.StartDate, request.EndDate);
            }

           
            return request.ReportType switch
            {
                "sales" => reports.OrderByDescending(r => r.TotalQuantitySold).ToList(),
                "revenue" => reports.OrderByDescending(r => r.TotalRevenue).ToList(),
                "frequency" => reports.OrderByDescending(r => r.SalesFrequency).ToList(),
                _ => reports.OrderByDescending(r => r.TotalRevenue).ToList()
            };
        }

        public async Task<ProductSalesReport> GetProductSalesReportById(int productId, ProductSalesReportRequest request)
        {
            var query = from oi in _context.OrderItems
                       join o in _context.Orders on oi.OrderId equals o.OrderId
                       join p in _context.Products on oi.ProductId equals p.Id
                       where p.Id == productId 
                             && (request.StartDate == DateTime.MinValue || o.OrderDate >= request.StartDate)
                             && (request.EndDate == DateTime.MinValue || o.OrderDate <= request.EndDate)
                       group new { oi, o, p } by new { p.Id, p.Name, p.Code } into g
                       select new ProductSalesReport
                       {
                           ProductId = g.Key.Id,
                           ProductName = g.Key.Name,
                           ProductCode = g.Key.Code,
                           TotalQuantitySold = g.Sum(x => x.oi.Quantity),
                           TotalRevenue = g.Sum(x => x.oi.Quantity * (decimal)x.oi.Price),
                           SalesFrequency = g.Count(),
                           AveragePrice = g.Average(x => (decimal)x.oi.Price),
                           ReportStartDate = request.StartDate,
                           ReportEndDate = request.EndDate,
                           ReportType = request.ReportType
                       };

            var report = await query.FirstOrDefaultAsync();

            if (report != null)
            {
                report.DailySales = await GetDailySalesData(productId, request.StartDate, request.EndDate);
            }

            return report ?? new ProductSalesReport
            {
                ProductId = productId,
                ReportStartDate = request.StartDate,
                ReportEndDate = request.EndDate,
                ReportType = request.ReportType
            };
        }

        public async Task<object> GetSalesSummary(ProductSalesReportRequest request)
        {
            var summary = await (from oi in _context.OrderItems
                                join o in _context.Orders on oi.OrderId equals o.OrderId
                                where (request.StartDate == DateTime.MinValue || o.OrderDate >= request.StartDate)
                                      && (request.EndDate == DateTime.MinValue || o.OrderDate <= request.EndDate)
                                group new { oi, o } by 1 into g
                                select new
                                {
                                    TotalProductsSold = g.Sum(x => x.oi.Quantity),
                                    TotalRevenue = g.Sum(x => x.oi.Quantity * (decimal)x.oi.Price),
                                    TotalOrders = g.Select(x => x.o.OrderId).Distinct().Count(),
                                    AverageOrderValue = g.Sum(x => x.oi.Quantity * (decimal)x.oi.Price) / g.Select(x => x.o.OrderId).Distinct().Count(),
                                    DateRange = $"{request.StartDate:yyyy-MM-dd} to {request.EndDate:yyyy-MM-dd}",
                                    ReportType = request.ReportType
                                }).FirstOrDefaultAsync();

            return summary ?? new
            {
                TotalProductsSold = 0,
                TotalRevenue = 0m,
                TotalOrders = 0,
                AverageOrderValue = 0m,
                DateRange = $"{request.StartDate:yyyy-MM-dd} to {request.EndDate:yyyy-MM-dd}",
                ReportType = request.ReportType
            };
        }

        private async Task<List<DailySalesData>> GetDailySalesData(int productId, DateTime startDate, DateTime endDate)
        {
            var dailyData = await (from oi in _context.OrderItems
                                  join o in _context.Orders on oi.OrderId equals o.OrderId
                                  where oi.ProductId == productId 
                                        && (startDate == DateTime.MinValue || o.OrderDate >= startDate)
                                        && (endDate == DateTime.MinValue || o.OrderDate <= endDate)
                                  group new { oi, o } by o.OrderDate.Date into g
                                  select new DailySalesData
                                  {
                                      Date = g.Key,
                                      QuantitySold = g.Sum(x => x.oi.Quantity),
                                      Revenue = g.Sum(x => x.oi.Quantity * (decimal)x.oi.Price),
                                      SalesCount = g.Count()
                                  }).ToListAsync();

                    
            var allDates = Enumerable.Range(0, (endDate - startDate).Days + 1)
                                   .Select(d => startDate.AddDays(d).Date);

            var result = new List<DailySalesData>();
            foreach (var date in allDates)
            {
                var existingData = dailyData.FirstOrDefault(d => d.Date == date);
                result.Add(existingData ?? new DailySalesData
                {
                    Date = date,
                    QuantitySold = 0,
                    Revenue = 0,
                    SalesCount = 0
                });
            }

            return result.OrderBy(d => d.Date).ToList();
        }
    }
}
