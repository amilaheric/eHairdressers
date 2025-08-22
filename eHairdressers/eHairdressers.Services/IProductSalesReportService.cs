using eHairdressers.Model;
using eHairdressers.Model.Requests;

namespace eHairdressers.Services
{
    public interface IProductSalesReportService
    {
        Task<List<ProductSalesReport>> GetProductSalesReport(ProductSalesReportRequest request);
        Task<ProductSalesReport> GetProductSalesReportById(int productId, ProductSalesReportRequest request);
        Task<object> GetSalesSummary(ProductSalesReportRequest request);
    }
}
