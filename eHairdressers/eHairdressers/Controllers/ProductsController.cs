using AutoMapper;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services;
using eHairdressers.Services.Database;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore.Storage;

namespace eHairdressers.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class ProductsController : BaseCRUDController<Model.Products, ProductsSearchObject,ProductInsertRequest,ProductUpdateRequest> 
    {
        public ProductsController(ILogger<BaseController<Model.Products, ProductsSearchObject>> _logger, IProductsService _service) : base(_logger, _service)
        {
        }

        [HttpPut("{id}/activate")]

        public virtual async Task<Model.Products> Activate(int id)
        {
            return await (_service as IProductsService).Activate(id);
        }

        [HttpPut("{id}/hide")]

        public virtual async Task<Model.Products> Hide(int id)
        {
            return await (_service as IProductsService).Hide(id);
        }

        [HttpGet("{id}/allowedActions")]

        public virtual async Task<List<string>> AllowedActions(int id)
        {
            return await (_service as IProductsService).AllowedActions(id);
        }

    }
}
