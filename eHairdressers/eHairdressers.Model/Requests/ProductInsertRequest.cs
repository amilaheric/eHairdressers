using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model.Requests
{
    public class ProductInsertRequest
    {
        public string Name { get; set; }
        public string? Description { get; set; }
        public double? Price { get; set; }
        public string Code { get; set; }
        public int? CategoryId { get; set; }
        public int? BrandId { get; set; }
        public byte[]? Image { get; set; }
        public byte[]? ImageThumb { get; set; }
        public string? PaymentId { get; set; }


    }
}
