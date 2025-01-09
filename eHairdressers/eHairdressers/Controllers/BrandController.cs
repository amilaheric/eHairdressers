using eHairdressers.Model;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    public class BrandController : BaseController<Model.Brand,BaseSearchObject>
    {
        public BrandController(ILogger<BaseController<Brand, BaseSearchObject>> _logger, IService<Brand, BaseSearchObject> _service) : base(_logger, _service)
        {
        }

       
    }
}
