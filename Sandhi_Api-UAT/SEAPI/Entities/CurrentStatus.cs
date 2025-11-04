using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Entities
{
	public class CurrentStatus
    {
        public long Id { get; set; }
        public long CSS_Id { get; set; }
        public string CSS_Code { get; set; }
        public string CSS_Name { get; set; }
        public string Business_Unit { get; set; }
        public string Vendor_Code { get; set; }
        public string Email_Id { get; set; }
        public string MonthName { get; set; }
        public string Inv_No { get; set; }
        public DateTime Inv_Date { get; set; }
        public decimal Inv_Amt { get; set; }
        public decimal Tax_Amt { get; set; }
        public decimal Inc_Tax_Amt { get; set; }
        public int? WO_COUNT { get; set; }
        public DateTime? CSS_Approved_Date { get; set; }
        public DateTime? CSS_Mgr_Approved_Date { get; set; }
        public DateTime? PRF_Gen_Date { get; set; }
        public DateTime? Invoice_Gen_Date { get; set; }
        public DateTime? Fin_Approved_Date { get; set; }
        public DateTime? GRN_Gen_Date { get; set; }
        public DateTime? Invoice_Paid_Date { get; set; }
        public string Gid { get; set; }
        public DateTime Created_Date { get; set; }
        public DateTime? Central_Approved_date { get; set; }
        public string Region { get; set; }
        public DateTime? Wo_Uploaded_Date { get; set; }

        public int? Invoice_Status_Type { get; set; }

    }
}
