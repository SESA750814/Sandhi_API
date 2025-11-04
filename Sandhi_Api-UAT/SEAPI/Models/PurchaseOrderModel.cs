using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class PurchaseOrderModel
    {
        public long Id { get; set; }
        public long CSS_Id { get; set; }
        public string CSS_Code { get; set; }
        public string CSS_Name { get; set; }
        public string PO_NO { get; set; }
        public DateTime PO_Date { get; set; }
        public decimal HBN_WARRANTY_AMT { get; set; }
        public decimal AVAILABLE_HBN_WARRANTY_AMT { get; set; }
        public decimal HBN_AMC_AMT { get; set; }
        public decimal AVAILABLE_HBN_AMC_AMT { get; set; }
        public decimal LABOR_AMC_AMT { get; set; }
        public decimal AVAILABLE_LABOR_AMC_AMT { get; set; }
        public decimal SUPPLY_AMC_AMT { get; set; }
        public decimal AVAILABLE_SUPPLY_AMC_AMT { get; set; }
        public decimal LABOR_WARRANTY_AMT { get; set; }
        public decimal AVAILABLE_LABOR_WARRANTY_AMT { get; set; }
        public decimal SUPPLY_WARRANTY_AMT { get; set; }
        public decimal AVAILABLE_SUPPLY_WARRANTY_AMT { get; set; }
        public decimal BASIC_AMT { get; set; }
        public decimal AVAILABLE_BASIC_AMT { get; set; }

        public DateTime Valid_From { get; set; }
        public DateTime? Valid_Till { get; set; }
        public string Status { get; set; }
        public string Updated_User { get; set; }
        public DateTime Updated_Date { get; set; }
        public string Remarks { get; set; }
    }
}
