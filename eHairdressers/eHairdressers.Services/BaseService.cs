using AutoMapper;
using eHairdressers.Model;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public class BaseService<T,TDb, TSearch>:IService<T,TSearch> where T : class where TDb : class where TSearch : BaseSearchObject
    {
        protected eHairdressersContext _context;
        public IMapper _mapper;
        public BaseService(eHairdressersContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
        }

        public virtual async Task<PageResult<T>> Get(TSearch? search = null)
        {
            var query = _context.Set<TDb>().AsQueryable();

            PageResult<T> result = new PageResult<T>();

            query = AddFilter(query, search);
            query = AddInclude(query, search);
            query = AddSorting(query, search);

            result.Count = await query.CountAsync();

            if (search?.Page.HasValue == true && search?.PageSize.HasValue == true) {
            query = query.Skip((search.Page.Value - 1) * search.PageSize.Value).Take(search.PageSize.Value);
            }

            var list = await query.ToListAsync();

            var tmp =_mapper.Map<List<T>>(list);
            result.Result = tmp;
            return result;

           
        }
        public virtual IQueryable<TDb> AddInclude(IQueryable<TDb> query, TSearch? search = null)
        {
            return query;
        }

        public virtual IQueryable<TDb> AddFilter(IQueryable<TDb> query, TSearch? search = null) {
            return query;
        }

        public virtual IQueryable<TDb> AddSorting(IQueryable<TDb> query, TSearch? search = null)
        {
            // Default implementation - can be overridden in derived classes
            return query;
        }
    }
}
