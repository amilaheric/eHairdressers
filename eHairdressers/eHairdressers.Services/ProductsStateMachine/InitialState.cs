using AutoMapper;
using eHairdressers.Model.Requests;
using eHairdressers.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.ProductsStateMachine
{
    public class InitialState : BaseState
    {
        public InitialState(IServiceProvider serviceProvider,eHairdressersContext context, IMapper mapper) : base(serviceProvider,context, mapper)
        {
        }

        public override async Task<Model.Products> Insert(ProductInsertRequest request)
        {
            var set = _context.Set<Products>();
            
            var entity = _mapper.Map<Products>(request);

            entity.StateMachine = "draft";

            set.Add(entity);

            await _context.SaveChangesAsync();



            return _mapper.Map<Model.Products>(entity);
        }


        public override async Task<List<string>> AllowedActions()
        {
            var list = await base.AllowedActions();

            list.Add("Insert");

            return list;
        }
    }
}
