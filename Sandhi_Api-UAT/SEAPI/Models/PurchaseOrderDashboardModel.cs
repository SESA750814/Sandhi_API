using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class PurchaseOrderDashboardModel
    {
        public string CSS_Code { get; set; }
        public string CSS_Name { get; set; }
        public string BusinessUnit { get; set; }
        public string Region { get; set; }
        public string  PO_NO { get; set; }
        public DateTime PO_DATE { get; set; }
        public decimal HBN_Warranty_Amount { get; set; }
        public decimal Available_HBN_Warranty_Amount { get; set; }
        public decimal HBN_AMC_Amount { get; set; }
        public decimal Available_HBN_AMC_Amount { get; set; }
        public decimal Labor_AMC_Amount { get; set; }
        public decimal Available_Labor_AMC_Amount { get; set; }
        public decimal Labor_Warranty_Amount { get; set; }
        public decimal Available_Labor_Warranty_Amount { get; set; }
        public decimal Supply_AMC_Amount { get; set; }
        public decimal Available_Supply_AMC_Amount { get; set; }
        public decimal Supply_Warranty_Amount { get; set; }
        public decimal Available_Supply_Warranty_Amount { get; set; }
        public decimal Basic_Amount { get; set; }
        public decimal Available_Basic_Amount { get; set; }
    }

}
