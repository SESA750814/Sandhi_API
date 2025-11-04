using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class PaymentDashboardCSSModelByValue
    {
        public int Ordinal { get; set; }
        public string CSS_Code { get; set; }
        public string CSS_Name { get; set; }
        public string BusinessUnit { get; set; }
        public string Region { get; set; }
        public decimal Month1 { get; set; }
        public decimal Month2 { get; set; }
        public decimal Month3 { get; set; }
    }

}
