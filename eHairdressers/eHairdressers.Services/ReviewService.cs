using AutoMapper;
using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;

namespace eHairdressers.Services
{
    public class ReviewService : BaseCRUDService<Review, Database.Reviews, BaseSearchObject, ReviewInsertRequest, ReviewUpdateRequest>, IReviewService
    {
        public ReviewService(eHairdressersContext context, IMapper mapper) : base(context, mapper)
        {
        }

        public async Task<List<Review>> GetReviewsByAppointmentId(int appointmentId)
        {
            var reviews = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Appointment)
                .Where(r => r.AppointmentId == appointmentId)
                .ToListAsync();

            return _mapper.Map<List<Review>>(reviews);
        }

        public async Task<List<Review>> GetReviewsByUserId(int userId)
        {
            var reviews = await _context.Reviews
                .Include(r => r.User)
                .Include(r => r.Appointment)
                .Where(r => r.UserId == userId)
                .ToListAsync();

            return _mapper.Map<List<Review>>(reviews);
        }

        public async Task<double> GetAverageRatingByAppointmentId(int appointmentId)
        {
            var averageRating = await _context.Reviews
                .Where(r => r.AppointmentId == appointmentId && r.Rate.HasValue)
                .AverageAsync(r => r.Rate.Value);

            return averageRating;
        }

        public override async Task<Review> Insert(ReviewInsertRequest insert)
        {
            
            var appointment = await _context.Appointments.FindAsync(insert.AppointmentId);
            if (appointment == null)
            {
                throw new Exception("Appointment not found");
            }

                                    
            var existingReview = await _context.Reviews
                .FirstOrDefaultAsync(r => r.AppointmentId == insert.AppointmentId && r.UserId == insert.UserId);

            if (existingReview != null)
            {
                throw new Exception("User has already reviewed this appointment");
            }

            return await base.Insert(insert);
        }

        public override async Task<Review> Update(int id, ReviewUpdateRequest update)
        {
            var existingReview = await _context.Reviews.FindAsync(id);
            if (existingReview == null)
            {
                throw new Exception("Review not found");
            }

            return await base.Update(id, update);
        }
    }
}
