using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Model.SearchObjects
{
    public class PaymentSearchObject : BaseSearchObject
    {
        public int? OrderId { get; set; }
        public string? PaymentStatus { get; set; }
        public string? PaymentMethod { get; set; }
        public DateTime? PaymentDateFrom { get; set; }
        public DateTime? PaymentDateTo { get; set; }
        public decimal? AmountMin { get; set; }
        public decimal? AmountMax { get; set; }
    }
}

