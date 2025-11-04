using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class PaymentDashboardModelByCount
    {
        public List<PaymentDashboardGroupModelByCount> paymentDashboardSummary { get; set; }
        public List<PaymentDashboardGroupModelByCount> paymentDashboardSummaryByRange { get; set; }
        public List<PaymentDashboardCSSModelByCount> paymentDashboardByCSS { get; set; }
    }

}
