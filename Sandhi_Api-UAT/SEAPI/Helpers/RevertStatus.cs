using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Helpers
{
    public static class RevertStatus
    {
        public static string GetRevertRule()
        {
            var revertRules = new Dictionary<(int fromStatusId, int toStatusId), List<string>>
            {
                {(9, 8), new List<string>
                    {
                        nameof(Invoice.Inv_No),
                        nameof(Invoice.Inv_Date),
                        nameof(Invoice.Inv_Attachment),
                        nameof(Invoice.Status_Type),
                        nameof(Invoice.Remarks),
                        nameof(Invoice.Updated_User),
                        nameof(Invoice.Updated_Date),
                        nameof(Invoice.INV_GEN_DATE)
                    }
                },
                {(9, 10), new List<string>
                    {
                        nameof(Invoice.Inv_No),
                        nameof(Invoice.Inv_Date),
                        nameof(Invoice.Inv_Attachment),
                        nameof(Invoice.Status_Type),
                        nameof(Invoice.Remarks),
                        nameof(Invoice.Updated_User),
                        nameof(Invoice.Updated_Date),
                        nameof(Invoice.INV_GEN_DATE)
                    }
                }
            };

            // Optional: return as JSON string for inspection
            return System.Text.Json.JsonSerializer.Serialize(revertRules);
        }
    }
}
//public enum StatusType
//{
//    [Description("Imported")]
//    Imported = -99,
//    [Description("Central Approved")]
//    Central_Approved = 0,
//    [Description("Central Rejected")]
//    Central_Rejected = 1,
//    [Description("CSS Validated")]
//    CSS_Validated = 2,
//    [Description("CSS Approved")]
//    CSS_Approved = 3,
//    [Description("CSS Discrepancy")]
//    CSS_Discrepancy = 4,
//    [Description("CSS Manager Approved")]
//    CSS_MGR_Approved = 5,
//    [Description("CSS Manager Discrepancy")]
//    CSS_MGR_Discrepancy = 6,
//    [Description("CSS Manager Approved Discrepancy")]
//    CSS_MGR_Approve_Discrepancy = 7,
//    [Description("PRF Raised")]
//    PRF_Raised = 8,
//    [Description("Waiting for PO")]
//    PO_Waiting = 9,
//    [Description("Invoice Raised")]
//    Invoice_Raised = 10,
//    [Description("Invoice Validated")]
//    Invoice_Validated = 11,
//    [Description("Invoice Rejected")]
//    Invoice_Rejected = 12,
//    [Description("GRN Clarification")]
//    GRN_Clarification = 13,
//    [Description("GRN Raised")]
//    GRN_Raised = 14,
//    [Description("Invoice Paid")]
//    Invoice_Paid = 15,
//    [Description("Zero Invoice Value")]
//    Zero_Value_Invoice = 16,
//}