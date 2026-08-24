using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin")]
    public class SalonOperationsReportController : ControllerBase
    {
        private readonly ISalonOperationsReportService _reportService;

        public SalonOperationsReportController(ISalonOperationsReportService reportService)
        {
            _reportService = reportService;
        }

        [HttpPost("SalonOperationsReport")]
        public async Task<IActionResult> GetSalonOperationsReport([FromBody] SalonOperationsReportRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var report = await _reportService.GetSalonOperationsReport(request);
                return Ok(new { success = true, data = report });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("SalonOperationsReport")]
        public async Task<IActionResult> GetSalonOperationsReportByQuery(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate,
            [FromQuery] string reportPeriod = "monthly")
        {
            try
            {
                var request = new SalonOperationsReportRequest
                {
                    StartDate = startDate,
                    EndDate = endDate,
                    ReportPeriod = reportPeriod
                };

                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var report = await _reportService.GetSalonOperationsReport(request);
                return Ok(new { success = true, data = report });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("SalonOperationsReport/Summary")]
        public async Task<IActionResult> GetSalonOperationsSummary(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate,
            [FromQuery] string reportPeriod = "monthly")
        {
            try
            {
                var request = new SalonOperationsReportRequest
                {
                    StartDate = startDate,
                    EndDate = endDate,
                    ReportPeriod = reportPeriod
                };

                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var summary = await _reportService.GetSalonOperationsSummary(request);
                return Ok(new { success = true, data = summary });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("SalonOperationsReport/FocusedSummary")]
        public async Task<IActionResult> GetSalonOperationsFocusedSummary(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate,
            [FromQuery] string reportPeriod = "monthly")
        {
            try
            {
                var request = new SalonOperationsReportRequest
                {
                    StartDate = startDate,
                    EndDate = endDate,
                    ReportPeriod = reportPeriod
                };

                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                var focusedSummary = await _reportService.GetSalonOperationsFocusedSummary(request);
                return Ok(new { success = true, data = focusedSummary });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }

        [HttpGet("SalonOperationsReport/History")]
        public async Task<IActionResult> GetSalonOperationsReportHistory(
            [FromQuery] DateTime startDate,
            [FromQuery] DateTime endDate)
        {
            try
            {
                var reports = await _reportService.GetSalonOperationsReportHistory(startDate, endDate);
                return Ok(new { success = true, data = reports });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = ex.Message });
            }
        }
    }
}
