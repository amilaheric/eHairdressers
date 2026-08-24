using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    public class OrdersController : BaseCRUDController<Model.Orders, OrdersSearchObject, OrdersInsertRequest, OrdersUpdateRequest>
    {
        public OrdersController(ILogger<BaseController<Model.Orders, OrdersSearchObject>> _logger, IOrdersService _service) : base(_logger, _service)
        {
        }

        [HttpPost]
        public override async Task<Model.Orders> Insert([FromBody] OrdersInsertRequest insert)
        {

            return await base.Insert(insert);
        }

    }
}
