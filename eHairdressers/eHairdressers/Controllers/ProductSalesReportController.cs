using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProductSalesReportController : ControllerBase
    {
        private readonly IProductSalesReportService _reportService;

        public ProductSalesReportController(IProductSalesReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpPost("ProductSalesReport")]
        public async Task<IActionResult> GetProductSalesReport([FromBody] ProductSalesReportRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var reports = await _reportService.GetProductSalesReport(request);
                return Ok(new { success = true, data = reports });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost("ProductSalesReport/{productId}")]
        public async Task<IActionResult> GetProductSalesReportById(int productId, [FromBody] ProductSalesReportRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var report = await _reportService.GetProductSalesReportById(productId, request);
                return Ok(new { success = true, data = report });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpPost("SalesSummary")]
        public async Task<IActionResult> GetSalesSummary([FromBody] ProductSalesReportRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var summary = await _reportService.GetSalesSummary(request);
                return Ok(new { success = true, data = summary });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("ProductSalesReport")]
        public async Task<IActionResult> GetProductSalesReportByQuery(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate,
            [FromQuery] string reportType = "revenue")
        {
            try
            {
                var request = new ProductSalesReportRequest
                {
                    StartDate = startDate,
                    EndDate = endDate,
                    ReportType = reportType
                };

                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var reports = await _reportService.GetProductSalesReport(request);
                return Ok(new { success = true, data = reports });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }
}
