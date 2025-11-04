using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.ResourceParameters
{
    public class WorkOrderStatusSubmitParameter
    {
        public string Month { get; set; }
        public string Status { get; set; }
        public string BusinessUnit { get; set; }
        public string UserName { get; set; }
        public string Remarks { get; set; }
        public string Reason { get; set; }
        public string ReasonDesc { get; set; }
        public string Attachment { get; set; }
        public decimal? WOAmount { get; set; }
        public string WOIds { get; set; }
        public long CSSId { get; set; }
        public decimal? LabourAmount { get; set; }
        public decimal? SupplyAmount { get; set; }
    }
}
