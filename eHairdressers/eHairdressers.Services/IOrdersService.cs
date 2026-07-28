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
    public interface IOrdersService:ICRUDService<Model.Orders,OrdersSearchObject,OrdersInsertRequest,OrdersUpdateRequest>
    {
                        
        Task UpdateOrderTotalPrice(int orderId);
        
       
        Task<double> GetOrderTotalPrice(int orderId);
        
       
        Task RecalculateAllOrderTotals();

        Task<int> SyncOrderStatusFromPayments();


    }
}
