using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    public class OrdersController : BaseCRUDController<Model.Orders, OrdersSearchObject, OrdersInsertRequest, OrdersUpdateRequest>
    {
        public OrdersController(ILogger<BaseController<Orders, OrdersSearchObject>> logger, ICRUDService<Orders, OrdersSearchObject, OrdersInsertRequest, OrdersUpdateRequest> service) : base(logger, service)
        {
        }
    }
}
