using eHairdressers.Model;
using eHairdressers.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace eHairdressers.Controllers
{
    [Route("[controller]")]
    [Authorize]
    public class BaseController<T,TSearch> : ControllerBase where T : class where TSearch : class
    {
        private readonly IService<T,TSearch> service;
        private readonly ILogger<BaseController<T,TSearch>> logger;
        public BaseController(ILogger<BaseController<T,TSearch>> _logger,IService<T,TSearch> _service)
        {
            logger= _logger;
            service= _service;
        }

        [HttpGet]

        public async Task<PageResult<T>> Get([FromQuery] TSearch? search = null)
        {
            return await service.Get(search);
        }
    }
}
