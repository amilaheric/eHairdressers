using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model.SearchObjects
{
    public class ProductsSearchObject:BaseSearchObject
    {
        public string? Name { get; set; }
        public int? BrandId { get; set; }
        public int? CategoryId { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
    }
}
