using AutoMapper;
using eHairdressers.Model.Requests;
using eHairdressers.Services.Database;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.ProductsStateMachine
{
    public class DraftProductState : BaseState
    {
        protected ILogger<DraftProductState> _logger;
        public DraftProductState(ILogger<DraftProductState> logger,IServiceProvider serviceProvider,eHairdressersContext context, IMapper mapper) : base(serviceProvider,context, mapper)
        {
            _logger = logger;
        }

        public override async Task<Model.Products> Update(int id,ProductUpdateRequest request)
        {
           var set = _context.Set<Products>();
            var entity = await set.FindAsync(id);

            _mapper.Map<Products>(entity);

           await _context.SaveChangesAsync();

            return _mapper.Map<Model.Products>(entity);
        }

        public override async Task<Model.Products> Activate(int id)
        {
            _logger.LogInformation($"Aktivacija proizvoda {id}");

            var set = _context.Set<Products>();

            var entity = await set.FindAsync(id);

            entity.StateMachine = "active";

            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Products>(entity);
        }

        public override async Task<List<string>> AllowedActions()
        {
            var list = await base.AllowedActions();

            list.Add("Update");
            list.Add("Activate");

            return list;
        }
    }
}
