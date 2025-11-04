using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Entities
{
    public class PurchaseOrder
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }
        [ForeignKey("CSS")]
        public long CSS_Id { get; set; }
        public string PO_NO { get; set; }
        public DateTime PO_Date { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal HBN_WARRANTY_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal AVAILABLE_HBN_WARRANTY_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal HBN_AMC_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal AVAILABLE_HBN_AMC_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal LABOR_AMC_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal AVAILABLE_LABOR_AMC_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal SUPPLY_AMC_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal AVAILABLE_SUPPLY_AMC_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal LABOR_WARRANTY_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal AVAILABLE_LABOR_WARRANTY_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal SUPPLY_WARRANTY_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal AVAILABLE_SUPPLY_WARRANTY_AMT { get; set; }



        [Column(TypeName = "decimal(18,2)")]
        public decimal BASIC_AMT { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal AVAILABLE_BASIC_AMT { get; set; }



        public DateTime Valid_From { get; set; }
        public DateTime? Valid_Till { get; set; }
        public string Status { get; set; }
        public string Updated_User { get; set; }
        public DateTime Updated_Date { get; set; }
        public string Remarks { get; set; }
        public string Month_Name { get; set; }

        public CSS CSS { get; set; }
    }

}
