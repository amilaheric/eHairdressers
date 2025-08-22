using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;

namespace eHairdressers.Services
{
    public interface IOrderItemsService : ICRUDService<OrderItems, OrderItemsSearchObject, OrderItemsInsertRequest, OrderItemsUpdateRequest>
    {
        Task<List<OrderItems>> GetOrderItemsByOrderIdAsync(int orderId);
    }
}
