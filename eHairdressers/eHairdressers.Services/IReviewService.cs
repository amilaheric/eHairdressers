using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;

namespace eHairdressers.Services
{
    public interface IReviewService : ICRUDService<Review, BaseSearchObject, ReviewInsertRequest, ReviewUpdateRequest>
    {
        Task<List<Review>> GetReviewsByAppointmentId(int appointmentId);
        Task<List<Review>> GetReviewsByUserId(int userId);
        Task<double> GetAverageRatingByAppointmentId(int appointmentId);
    }
}
