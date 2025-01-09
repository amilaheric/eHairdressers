using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model.Requests
{
    public class ProductUpdateRequest
    {
        public string Name { get; set; }
        public string? Description { get; set; }
        public decimal Price { get; set; }
        public int? CategoryId { get; set; }
        public int? BrandId { get; set; }
        public byte[]? Image { get; set; }
        public byte[]? ImageThumb { get; set; }
    }
}
