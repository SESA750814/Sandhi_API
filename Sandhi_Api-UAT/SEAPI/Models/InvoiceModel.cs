using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class InvoiceModel
    {
        public long Id { get; set; }
        public long CSS_Id { get; set; }
        public string CSS_Code { get; set; }
        public string Vendor_Code { get; set; }
        public string CSS_Name { get; set; }
        public string CSS_Short_Name { get; set; }
        public string Region { get; set; }
        public string Email_ID { get; set; }
        public string PO_NO { get; set; }
        public DateTime PO_Date { get; set; }
        public string Inv_Type { get; set; }
        public string WO_BusinessUnit { get; set; }
        public decimal WO_Amt { get; set; }
        public long WO_COUNT { get; set; }
        public decimal Base_Payout { get; set; }
        public decimal Incentive_Amt { get; set; }
        public decimal Ded_Amt { get; set; }
        public decimal Inv_Amt { get; set; }
        public decimal Tax_Amt { get; set; }
        public decimal Inc_Tax_Amt { get; set; }
        public string PRF_No { get; set; }
        public DateTime PRF_Gen_Date { get; set; }
        public string Inv_No { get; set; }
        public DateTime? Inv_Date { get; set; }
        public string GRN_No { get; set; }
        public DateTime? GRN_Date { get; set; }
        public DateTime? No_Due_Date { get; set; }
        public DateTime? Payment_Process_Date { get; set; }
        public int Status_Type { get; set; }

        public string Updated_User { get; set; }
        public DateTime Updated_Date { get; set; }
        public string Remarks { get; set; }

        public string Month_Name { get; set; }



        public DateTime? INV_GEN_DATE { get; set; }

        public DateTime? GRN_GEN_DATE { get; set; }
        public DateTime? FIN_APPROVE_DATE { get; set; }
        public DateTime?  INV_PAID_DATE { get; set; }
        public string Inv_Attachment { get; set; }
        public string CSS_Name_as_per_Oracle_SAP { get; set; }
        public PurchaseOrderModel PurchaseOrder { get; set; }
        public IEnumerable<InvoiceDetailModel> InvoiceDetails { get; set; }
        public ICollection<WorkOrderModel> WorkOrders { get; set; }
        public ICollection<WorkOrderModel> SupplyWorkOrders { get; set; }
        public ICollection<WorkOrderStatusModel> WorkOrderStatuses { get; set; }


    }
}
