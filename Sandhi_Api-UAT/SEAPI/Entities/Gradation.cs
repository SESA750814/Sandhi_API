using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Entities
{
    public class Gradation
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }
        [ForeignKey("CSS")]
        public long CSS_Id { get; set; }
        public DateTime Valid_From { get; set; }
        public DateTime Valid_Till { get; set; }

        public string SRS_GRADE { get; set; }
        public string NSS_GRADE { get; set; }
        public string CSR_GRADE { get; set; }
        public string WOR_GRADE { get; set; }
        public string MTTR_GRADE { get; set; }
        public string PMC_GRADE { get; set; }
        public string DFR_HBN_GRADE { get; set; }
        public string DFR_PPI_GRADE { get; set; }
        public string NPF_GRADE { get; set; }
        public string ATTR_GRADE { get; set; }
        public string FRS_GRADE { get; set; }
        public string LEAD_GRADE { get; set; }
        public string IB_GRADE { get; set; }
        public string FINAL_GRADE { get; set; }
        public string UPDATED_USER { get; set; }
        public DateTime UPDATED_DATE { get; set; }
        public string GradationEligibility { get; set; }

        public  IEnumerable<GradationDetail> GradationDetails { get; set; }
        public CSS CSS { get; set; }

    }

}
