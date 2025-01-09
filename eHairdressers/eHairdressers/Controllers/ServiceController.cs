using eHairdressers.Model;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    public class ServiceController : BaseController<Model.Service, BaseSearchObject>
    {
        public ServiceController(ILogger<BaseController<Service, BaseSearchObject>> _logger, IService<Service, BaseSearchObject> _service) : base(_logger, _service)
        {
        }


    }
}
