using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eHairdressers.Services.Database
{
    public class Payment
    {
        public int PaymentId { get; set; }
        public int OrderId { get; set; }
        public DateTime PaymentDate { get; set; }
        public decimal Amount { get; set; }
        public string PaymentMethod { get; set; } = null!;
        public string PaymentStatus { get; set; }

        [MaxLength(255)]
        public string? StripePaymentIntentId { get; set; }

        public virtual Orders Order { get; set; } = null!;
    }
}
