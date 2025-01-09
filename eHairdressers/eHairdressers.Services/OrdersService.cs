using AutoMapper;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public class OrdersService : BaseCRUDService<Model.Orders, Database.Orders, OrdersSearchObject, OrdersInsertRequest, OrdersUpdateRequest>, IOrders
    {
        public OrdersService(eHairdressersContext context, IMapper mapper) : base(context, mapper)
        {
        }
    }
}
