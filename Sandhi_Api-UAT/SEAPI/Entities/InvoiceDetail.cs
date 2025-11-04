using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Entities
{
    public class InvoiceDetail
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }
        [ForeignKey("Invoice")]
        public long INV_ID { get; set; }
        public string AMC_WARRANTY_FLAG { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal INV_AMT { get; set; }
        public string Updated_User { get; set; }
        public DateTime Updated_Date { get; set; }
        public Invoice Invoice { get; set; }
    }

}
