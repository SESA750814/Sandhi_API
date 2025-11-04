using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class PaymentDashboardModelByValue
    {
        public List<PaymentDashboardGroupModelByValue> paymentDashboardSummary { get; set; }
        public List<PaymentDashboardGroupModelByValue> paymentDashboardSummaryByRange { get; set; }
        public List<PaymentDashboardCSSModelByValue> paymentDashboardByCSS { get; set; }
    }

}
