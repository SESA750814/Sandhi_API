using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models

{
    public class WorkOrderStatusModel
    {
        public long Id { get; set; }
        public int Work_Order_Id { get; set; }
        public int Status_Type { get; set; }
        public string Updated_User { get; set; }
        public bool Auto_Approval { get; set; }
        public decimal Wo_Amt { get; set; }
        public decimal? LABOUR_COST { get; set; }
        public decimal? SUPPLY_COST { get; set; }
        public DateTime Updated_Date { get; set; }
        public string Remarks { get; set; }
        public string Reason { get; set; }
        public string Reason_Desc { get; set; }
        public string Attachment { get; set; }

        public WorkOrderModel WorkOrder { get; set; }
    }

    public enum StatusType
    {
        [Description("Imported")]
        Imported=-99,
        [Description("Central Approved")]
        Central_Approved = 0,
        [Description("Central Rejected")]
        Central_Rejected = 1,
        [Description("CSS Validated")]
        CSS_Validated = 2,
        [Description("CSS Approved")]
        CSS_Approved = 3,
        [Description("CSS Discrepancy")]
        CSS_Discrepancy = 4,
        [Description("CSS Manager Approved")]
        CSS_MGR_Approved = 5,
        [Description("CSS Manager Discrepancy")]
        CSS_MGR_Discrepancy = 6,
        [Description("CSS Manager Approved Discrepancy")]
        CSS_MGR_Approve_Discrepancy = 7,
        [Description("PRF Raised")]
        PRF_Raised = 8,
        [Description("Waiting for PO")]
        PO_Waiting = 9,
        [Description("Invoice Raised")]
        Invoice_Raised = 10,
        [Description("Invoice Validated")]
        Invoice_Validated = 11,
        [Description("Invoice Rejected")]
        Invoice_Rejected = 12,
        [Description("GRN Clarification")]
        GRN_Clarification = 13,
        [Description("GRN Raised")]
        GRN_Raised = 14,
        [Description("Invoice Paid")]
        Invoice_Paid = 15,
        [Description("Zero Invoice Value")]
        Zero_Value_Invoice = 16,
    }
}
