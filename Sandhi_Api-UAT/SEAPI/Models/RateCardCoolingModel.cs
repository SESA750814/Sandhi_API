using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class RateCardCoolingModel
    {
        public int? Id { get; set; }
        public string Sr_no { get; set; }
        public string Payout_Type { get; set; }
        public string Work_Description { get; set; }
        public string Description { get; set; }
        public string Short_Description { get; set; }
        public string Unit_details { get; set; }
        public string Product_Grouping { get; set; }
        public string CSS_Code { get; set; }
        public string Region { get; set; }
        public string Distance_Slab { get; set; }
        public string Rate { get; set; }

    }
}
