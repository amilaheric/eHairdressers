using eHairdressers.Model;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    [ApiController]

    public class CategoryController : BaseController<Model.Category,BaseSearchObject>
    {
        public CategoryController(ILogger<BaseController<Category, BaseSearchObject>> _logger, IService<Category, BaseSearchObject> _service) : base(_logger, _service)
        {
        }
    }
}
