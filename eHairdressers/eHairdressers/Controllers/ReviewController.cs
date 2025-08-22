using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    public class ReviewController : BaseCRUDController<Model.Review, BaseSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {
        private readonly IReviewService _reviewService;

        public ReviewController(ILogger<BaseController<Review, BaseSearchObject>> logger, IReviewService service) : base(logger, service)
        {
            _reviewService = service;
        }

        [HttpGet("appointment/{appointmentId}")]
        public async Task<List<Review>> GetReviewsByAppointmentId(int appointmentId)
        {
            return await _reviewService.GetReviewsByAppointmentId(appointmentId);
        }

        [HttpGet("user/{userId}")]
        public async Task<List<Review>> GetReviewsByUserId(int userId)
        {
            return await _reviewService.GetReviewsByUserId(userId);
        }

        [HttpGet("average-rating/{appointmentId}")]
        public async Task<ActionResult<double>> GetAverageRatingByAppointmentId(int appointmentId)
        {
            try
            {
                var averageRating = await _reviewService.GetAverageRatingByAppointmentId(appointmentId);
                return Ok(averageRating);
            }
            catch (InvalidOperationException)
            {
                return Ok(0.0);
            }
        }

        [HttpGet("available-appointments/{userId}")]
        public async Task<List<Model.Appointment>> GetAvailableAppointmentsForReview(int userId)
        {
           
            var appointmentService = HttpContext.RequestServices.GetService<IAppointmentService>();
            if (appointmentService == null)
            {
                throw new InvalidOperationException("AppointmentService not available");
            }
            
            return await appointmentService.GetCompletedAppointmentsForReviewAsync(userId);
        }



        [HttpPost]
        public override async Task<Review> Insert([FromBody] ReviewInsertRequest insert)
        {
            return await base.Insert(insert);
        }

        [HttpPut("{id}")]
        public override async Task<Review> Update(int id, [FromBody] ReviewUpdateRequest update)
        {
            return await base.Update(id, update);
        }
    }
}
