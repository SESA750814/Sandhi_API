using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class PaymentDashboardGroupModelByValue
    {
        public int Ordinal { get; set; }
        public string HeaderTyp { get; set; }
        public string Region { get; set; }
        public decimal Cooling_Month1 { get; set; }
        public decimal Cooling_Month2 { get; set; }
        public decimal Cooling_Month3 { get; set; }
        public decimal HBN_Month1 { get; set; }
        public decimal HBN_Month2 { get; set; }
        public decimal HBN_Month3 { get; set; }

        public decimal PPI_Month1 { get; set; }
        public decimal PPI_Month2 { get; set; }
        public decimal PPI_Month3 { get; set; }
    }

}
