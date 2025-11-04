using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class ReportWorkOrderSemiDraft
    {
        public string Css_Id { get; set; }
        public string Css_Code { get; set; }
        public string CSS_Name { get; set; }
        public string Region { get; set; }
        public string Month_Name { get; set; }
        public string Business_Unit { get; set; }

        public int WorkOrderCount { get; set; }
        public int CSSValidatedCount { get; set; }
        public int CSSApprovedCount { get; set; }
        public int CSSDiscrepancyCount { get; set; }
        public int CSSManagerApprovedDiscrepancyCount { get; set; }

    }

}
