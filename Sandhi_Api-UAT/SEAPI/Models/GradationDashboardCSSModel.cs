using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class GradationDashboardCSSModel
    {
        public string CSS_CODE { get; set; }
        public string CSS_NAME { get; set; }
        public string Region { get; set; }
        public string BusinessUnit { get; set; }
        public string Month_Name { get; set; }

        public string FINAL_GRADE { get; set; }
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

    }

}
