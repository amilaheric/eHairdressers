using AutoMapper;
using eHairdressers.Services.Database;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.ProductsStateMachine
{
    public class ActiveProductState : BaseState
    {
        public ActiveProductState(IServiceProvider serviceProvider,eHairdressersContext context, IMapper mapper) : base(serviceProvider,context, mapper)
        {
        }

        public override async Task<Model.Products> Hide(int id)
        {
            var set = _context.Set<Products>();

            var entity = await set.FindAsync(id);

            entity.StateMachine = "draft";

            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Products>(entity);
        }

        public override async Task<List<string>> AllowedActions()
        {
            var list = await base.AllowedActions();

            list.Add("Hide");
        
            return list;
        }
    }
}
