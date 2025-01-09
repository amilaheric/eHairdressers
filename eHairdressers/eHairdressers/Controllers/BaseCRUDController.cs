using eHairdressers.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using static Microsoft.EntityFrameworkCore.DbLoggerCategory;

namespace eHairdressers.Controllers
{
    public class BaseCRUDController<T,TSearch, TInsert, TUpdate> : BaseController<T,TSearch> where T : class where TSearch: class
    {
        protected new readonly ICRUDService<T, TSearch, TInsert, TUpdate> _service;
        protected readonly ILogger<BaseController<T,TSearch>> _logger;

        public BaseCRUDController(ILogger<BaseController<T, TSearch>> logger, ICRUDService<T, TSearch, TInsert, TUpdate> service) : base(logger, service)
        {
            _service = service;
            _logger = logger;
        }

        [HttpPost]
        public virtual async Task<T> Insert(TInsert insert)
        {
            return await _service.Insert(insert);
        }

        [HttpPut("{id}")]
        public virtual async Task<T> Update(int id,TUpdate update)
        {
            return await _service.Update(id,update);
        }

        [HttpDelete("{id}")]
        public virtual async Task<T> Delete(int id)
        {
            return await _service.Delete(id);
        }

    }
}
