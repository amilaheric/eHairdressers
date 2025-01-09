using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public interface IOrders:ICRUDService<Model.Orders,OrdersSearchObject,OrdersInsertRequest,OrdersUpdateRequest>
    {
    }
}
