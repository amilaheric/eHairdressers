using AutoMapper;
using eHairdressers.Model.Requests;
using eHairdressers.Model.SearchObjects;
using eHairdressers.Services.Database;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace eHairdressers.Services
{
    public class ProductsService: BaseCRUDService<Model.Products,Database.Products,ProductsSearchObject,ProductInsertRequest,ProductUpdateRequest>, IProductsService
    {
        public ProductsService(eHairdressersContext context, IMapper mapper) : base(context, mapper)
        {
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

        public override async Task<Model.Products> Insert(ProductInsertRequest insert)
        {
           
            if (insert.CategoryId.HasValue)
            {
                var category = await _context.Category.FindAsync(insert.CategoryId.Value);
                if (category == null)
                    throw new Exception("Category not found");
            }

           
            if (insert.BrandId.HasValue)
            {
                var brand = await _context.Brand.FindAsync(insert.BrandId.Value);
                if (brand == null)
                    throw new Exception("Brand not found");
            }

            var product = new Database.Products
            {
                Name = insert.Name,
                Description = insert.Description ?? "",
                Price = insert.Price ?? 0,
                Code = insert.Code,
                CategoryId = insert.CategoryId ?? 0,
                BrandId = insert.BrandId ?? 0,
                Image = insert.Image,
                ImageThumb = insert.ImageThumb
            };

            _context.Products.Add(product);
            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Products>(product);
        }

        public override async Task<Model.Products> Update(int id, ProductUpdateRequest update)
        {
            var entity = await _context.Products.FindAsync(id);
            if (entity == null)
                throw new Exception("Product not found");

           
            if (update.CategoryId.HasValue)
            {
                var category = await _context.Category.FindAsync(update.CategoryId.Value);
                if (category == null)
                    throw new Exception("Category not found");
            }

           
            if (update.BrandId.HasValue)
            {
                var brand = await _context.Brand.FindAsync(update.BrandId.Value);
                if (brand == null)
                    throw new Exception("Brand not found");
            }

            entity.Name = update.Name;
            entity.Description = update.Description ?? entity.Description;
            entity.Price = (double)update.Price;
            entity.CategoryId = update.CategoryId ?? entity.CategoryId;
            entity.BrandId = update.BrandId ?? entity.BrandId;
            entity.Image = update.Image ?? entity.Image;
            entity.ImageThumb = update.ImageThumb ?? entity.ImageThumb;

            await _context.SaveChangesAsync();

            return _mapper.Map<Model.Products>(entity);
        }

        public async Task<Model.Products> Activate(int id)
        {
           
            var entity = await _context.Products.FindAsync(id);
            if (entity == null)
                throw new Exception("Product not found");

            return _mapper.Map<Model.Products>(entity);
        }

        public async Task<Model.Products> Hide(int id)
        {
           
            var entity = await _context.Products.FindAsync(id);
            if (entity == null)
                throw new Exception("Product not found");

            return _mapper.Map<Model.Products>(entity);
        }

        public async Task<List<string>> AllowedActions(int id)
        {
            
            var entity = await _context.Products.FindAsync(id);
            if (entity == null)
                throw new Exception("Product not found");

            return new List<string> { "view", "update", "delete" };
        }
    }
}
