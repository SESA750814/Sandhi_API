using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
	public class RateCardHBNModel
    {
        public int? Id { get; set; }
        public string Product_Grouping { get; set; }
        public string PayOut_Type { get; set; }
        public string Service_Type { get; set; }
        public string Distance_Slab { get; set; }
        public string Rate { get; set; }
    }
}
