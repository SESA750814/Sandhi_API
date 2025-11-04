using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class PaymentDashboardGroupModelByCount
    {
        public int Ordinal { get; set; }
        public string HeaderTyp { get; set; }
        public string Region { get; set; }
        public int Cooling_Month1 { get; set; }
        public int Cooling_Month2 { get; set; }
        public int Cooling_Month3 { get; set; }
        public int HBN_Month1 { get; set; }
        public int HBN_Month2 { get; set; }
        public int HBN_Month3 { get; set; }

        public int PPI_Month1 { get; set; }
        public int PPI_Month2 { get; set; }
        public int PPI_Month3 { get; set; }
    }

}
