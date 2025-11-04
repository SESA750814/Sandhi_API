using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Entities
{
    public class WorkOrderStatus
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }


        [ForeignKey("WorkOrder")]
        [Column("Work_Order_Id")]
        public long Work_Order_Id { get; set; }

        public int Status_Type { get; set; }

        [Column(TypeName = "varchar(100)")]
        public string Updated_User { get; set; }

        public DateTime Updated_Date { get; set; }

        public bool Auto_Approval { get; set; }

        public string Remarks { get; set; }

        [Column("WO_AMT", TypeName = "numeric(18,2)")]
        public decimal? Wo_Amt { get; set; }

        public string Reason { get; set; }

        public string Reason_Desc { get; set; }

        public string Attachment { get; set; }

        public decimal? LABOUR_COST { get; set; }

        public decimal? SUPPLY_COST { get; set; }

        public WorkOrder WorkOrder { get; set; }
    }

}
