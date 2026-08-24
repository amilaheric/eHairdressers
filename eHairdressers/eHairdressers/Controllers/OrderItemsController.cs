using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    [Route("OrderItems")]
    public class OrderItemsController : BaseCRUDController<Model.OrderItems, OrderItemsSearchObject, OrderItemsInsertRequest, OrderItemsUpdateRequest>
    {
        private readonly IOrderItemsService _orderItemsService;

        public OrderItemsController(ILogger<BaseController<Model.OrderItems, OrderItemsSearchObject>> _logger, IOrderItemsService _service) : base(_logger, _service)
        {
            _orderItemsService = _service;
        }

        [HttpGet("order/{orderId}")]
        public async Task<List<Model.OrderItems>> GetOrderItemsByOrderId(int orderId)
        {
            return await _orderItemsService.GetOrderItemsByOrderIdAsync(orderId);
        }

        [HttpPost]
        public override async Task<Model.OrderItems> Insert([FromBody] OrderItemsInsertRequest insert)
        {

            return await base.Insert(insert);
        }
    }
}
