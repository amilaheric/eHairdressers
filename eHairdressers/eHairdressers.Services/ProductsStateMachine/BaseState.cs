using AutoMapper;
using eHairdressers.Model;
using eHairdressers.Model.Requests;
using eHairdressers.Services.Database;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.ProductsStateMachine
{
    public class BaseState
    {
        protected eHairdressersContext _context;
        protected IMapper _mapper;
        public IServiceProvider _serviceprovider { get; set; }
        public BaseState(IServiceProvider serviceProvider,eHairdressersContext context, IMapper mapper)
        {
            _context = context;
            _mapper = mapper;
            _serviceprovider = serviceProvider;
        }


        public virtual Task<Model.Products> Insert(ProductInsertRequest request)
        {
            throw new UserException("Not allowed");
        }
        public virtual Task<Model.Products> Update(int id,ProductUpdateRequest request)
        {
            throw new UserException("Not allowed");
        }

        public virtual Task<Model.Products> Activate(int id)
        {
            throw new UserException("Not allowed");
        }

        public virtual Task<Model.Products> Hide(int id)
        {
            throw new UserException("Not allowed");
        }


        public BaseState CreateState(string stateName)
        {
            switch (stateName)
            {
                case "initial":
                case null:
                    return _serviceprovider.GetService<InitialState>();
                    break;
                case "draft":
                    return _serviceprovider.GetService<DraftProductState>();
                    break;
                case "active":
                    return _serviceprovider.GetService<ActiveProductState>();
                    break;
                default:
                    throw new UserException("Not allowed");

            }
        }
        public virtual async Task<List<string>> AllowedActions()
        {
            return new List<string>();
        }

    }
}
