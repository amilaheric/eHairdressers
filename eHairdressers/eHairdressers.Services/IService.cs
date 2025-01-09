using eHairdressers.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public interface IService<T, TSearch> where TSearch : class
    {
        Task<PageResult<T>> Get(TSearch search = null);
    }
}
