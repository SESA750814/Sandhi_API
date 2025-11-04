using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Entities
{
    public class InvoiceStatus
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }
        [ForeignKey("Invoice")]
        public long Inv_Id { get; set; }
        public int Status_Type { get; set; }

        public string Ref_No { get; set; }

        public DateTime? Ref_Date { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? Ref_Amt { get; set; }
        public string Remarks { get; set; }
        public string Attachment { get; set; }
        public string Updated_User { get; set; }
        public DateTime Updated_Date { get; set; }
        public bool Auto_Approval { get; set; }
        public Invoice Invoice { get; set; }
    }

}
