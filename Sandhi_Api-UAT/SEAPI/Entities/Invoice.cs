using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Entities
{
    public class Invoice
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }
        [ForeignKey("CSS")]
        [Column("CSS_ID")]
        public long CSS_Id { get; set; }
        [ForeignKey("PurchaseOrder")]
        public long? PO_Id { get; set; }

        [Column("INV_TYPE")]
        public string Inv_Type { get; set; }

        [Column("WO_BUSINESSUNIT")]
        public string WO_BusinessUnit { get; set; }

        [Column("WO_AMT", TypeName = "decimal(18,2)")]
        public decimal WO_Amt { get; set; }
        public long WO_COUNT { get; set; }

        [Column("BASE_PAYOUT", TypeName = "decimal(18,2)")]
        public decimal Base_Payout { get; set; }

        [Column("INCENTIVE_AMT", TypeName = "decimal(18,2)")]
        public decimal Incentive_Amt { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal Ded_Amt { get; set; }

        [Column("INV_AMT", TypeName = "decimal(18,2)")]
        public decimal Inv_Amt { get; set; }

        [Column("TAX_AMT", TypeName = "decimal(18,2)")]
        public decimal Tax_Amt { get; set; }

        [Column("INC_TAX_AMT", TypeName = "decimal(18,2)")]
        public decimal Inc_Tax_Amt { get; set; }
        [Column("PRF_NO")]
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
        public DateTime Created_Date { get; set; }

        public string Remarks { get; set; }
        public string Inv_Attachment { get; set; }

        public string Month_Name { get; set; }


        public DateTime? INV_GEN_DATE { get; set; }
        public DateTime? FIN_APPROVE_DATE { get; set; }
        public DateTime? PO_REQ_DATE { get; set; }
        public DateTime? PO_ASSIGN_DATE { get; set; }
        public DateTime? GRN_GEN_DATE { get; set; }
        public DateTime? INV_PAID_DATE { get; set; }
        public bool? IsGRNCollectoreMailSent { set; get; }
        public CSS CSS { get; set; }
        public PurchaseOrder PurchaseOrder { get; set; }
        public IEnumerable<InvoiceDetail> InvoiceDetails { get; set; }
        public IEnumerable<InvoiceStatus> InvoiceStatuses { get; set; }

        [InverseProperty(nameof(WorkOrder.Invoice))]
        public ICollection<WorkOrder> WorkOrders { get; set; }

        [InverseProperty(nameof(WorkOrder.SupplyInvoice))]
        public ICollection<WorkOrder> SupplyWorkOrders { get; set; }
    }

}
