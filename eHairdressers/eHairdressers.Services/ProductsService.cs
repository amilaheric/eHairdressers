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
                filteredQuery = filteredQuery.Where(x => x.Name.Contains(search.Name));
            }

            if (search?.BrandId.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.BrandId == search.BrandId.Value);
            }

            if (search?.CategoryId.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.CategoryId == search.CategoryId.Value);
            }

            if (search?.MinPrice.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.Price >= (double)search.MinPrice.Value);
            }

            if (search?.MaxPrice.HasValue == true)
            {
                filteredQuery = filteredQuery.Where(x => x.Price <= (double)search.MaxPrice.Value);
            }

            return filteredQuery;
        }

        public override IQueryable<Products> AddSorting(IQueryable<Products> query, ProductsSearchObject? search = null)
        {
            if (search?.SortBy != null)
            {
                var sortOrder = search.SortOrder?.ToLower() == "desc" ? "desc" : "asc";
                
                switch (search.SortBy.ToLower())
                {
                    case "name":
                        query = sortOrder == "desc" ? query.OrderByDescending(x => x.Name) : query.OrderBy(x => x.Name);
                        break;
                    case "price":
                        query = sortOrder == "desc" ? query.OrderByDescending(x => x.Price) : query.OrderBy(x => x.Price);
                        break;
                    case "code":
                        query = sortOrder == "desc" ? query.OrderByDescending(x => x.Code) : query.OrderBy(x => x.Code);
                        break;
                    case "categoryid":
                        query = sortOrder == "desc" ? query.OrderByDescending(x => x.CategoryId) : query.OrderBy(x => x.CategoryId);
                        break;
                    case "brandid":
                        query = sortOrder == "desc" ? query.OrderByDescending(x => x.BrandId) : query.OrderBy(x => x.BrandId);
                        break;
                    default:
                        // Default sort by name if unknown field
                        query = query.OrderBy(x => x.Name);
                        break;
                }
            }
            else
            {
                // Default sort by name if no sort specified
                query = query.OrderBy(x => x.Name);
            }
            
            return query;
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
