using AutoMapper;
using Azure.Core;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using eHairdressers.Services.ProductsStateMachine;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public class ProductsService: BaseCRUDService<Model.Products,Database.Products,ProductsSearchObject,ProductInsertRequest,ProductUpdateRequest>, IProductsService
    {
        public BaseState _baseState { get; set; }
        public ProductsService(BaseState baseState,eHairdressersContext context, IMapper mapper) : base(context, mapper)
        {
            _baseState = baseState;
        }

        public override IQueryable<Products> AddFilter(IQueryable<Products> query, ProductsSearchObject? search = null)
        {
            var filteredQuery = base.AddFilter(query, search);

            if (!string.IsNullOrWhiteSpace(search?.Name))
            {
                filteredQuery = filteredQuery.Where(x=>x.Name.Contains(search.Name));
            }

            return filteredQuery;
        }

        public override Task<Model.Products> Insert(ProductInsertRequest insert)
        {
            var state = _baseState.CreateState("initial");
            return state.Insert(insert);
        }

        public override async Task<Model.Products> Update(int id, ProductUpdateRequest update)
        {
            var entity = await _context.Products.FindAsync(id);
            var state = _baseState.CreateState(entity.StateMachine);
            return await state.Update(id, update);
        }

       public async Task<Model.Products> Activate(int id)
        {
            var entity = await _context.Products.FindAsync(id);

            var state = _baseState.CreateState(entity.StateMachine);

            return await state.Activate(id);
        
        }

        public async Task<Model.Products> Hide(int id)
        {
            var entity = await _context.Products.FindAsync(id);

            var state = _baseState.CreateState(entity.StateMachine);

            return await state.Hide(id);

        }


        public async Task<List<string>> AllowedActions(int id)
        {
            var entity = await _context.Products.FindAsync(id);
            var state = _baseState.CreateState(entity?.StateMachine ?? "initial");
            return await state.AllowedActions();

        }
    }
}
