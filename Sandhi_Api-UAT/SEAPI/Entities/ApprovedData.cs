using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Entities
{
	public class ApprovedData
    {
        public long Id { get; set; }
        public long CSS_Id { get; set; }
        public string CSS_Manager { get; set; }
        public string CSS_Name { get; set; }
        public string Region { get; set; }
        public string Month_Name { get; set; }
        public DateTime? Approval_Date { get; set; }
        public string Inv_Type { get; set; }
        public decimal? Inv_Amt { get; set; }
        public decimal? Tax_Amt { get; set; }
        public decimal? Inc_Tax_Amt { get; set; }
        public decimal? AMC_Amt { get; set; }
        public decimal? Warranty_Amt { get; set; }
        public long? Inv_Id { get; set; }
        public string PO_No { get; set; }
        public string Gid { get; set; }
        public IEnumerable<ApprovedDataWorkOrder> WorkOrders { get; set; }


    }
}
