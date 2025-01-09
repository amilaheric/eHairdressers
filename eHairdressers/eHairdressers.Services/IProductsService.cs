using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public interface IProductsService :ICRUDService<Model.Products,ProductsSearchObject, ProductInsertRequest, ProductUpdateRequest>
    {
        Task<Products> Activate(int id);
        Task<Products> Hide(int id);

        Task<List<string>> AllowedActions(int id);
    }
}
