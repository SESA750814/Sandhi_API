using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class GradationDashboardGroupModel
    {
        public string Region { get; set; }
        public string BusinessUnit { get; set; }
        public string Month_Name { get; set; }
        public int TOTAL_CSS { get; set; }
        public string Grade_Text { get; set; }

        public int FINAL_GRADE { get; set; }
        public int SRS_GRADE { get; set; }
        public decimal SRS_PERCENTAGE { get; set; }
        public int NSS_GRADE { get; set; }
        public decimal NSS_PERCENTAGE { get; set; }
        public int CSR_GRADE { get; set; }
        public decimal CSR_PERCENTAGE { get; set; }
        public int WOR_GRADE { get; set; }
        public decimal WOR_PERCENTAGE { get; set; }
        public int MTTR_GRADE { get; set; }
        public decimal MTTR_PERCENTAGE { get; set; }
        public int PMC_GRADE { get; set; }
        public decimal PMC_PERCENTAGE { get; set; }
        public int DFR_HBN_GRADE { get; set; }
        public decimal DFR_HBN_PERCENTAGE { get; set; }
        public int DFR_PPI_GRADE { get; set; }
        public decimal DFR_PPI_PERCENTAGE { get; set; }
        public int NPF_GRADE { get; set; }
        public decimal NPF_PERCENTAGE { get; set; }
        public int ATTR_GRADE { get; set; }
        public decimal ATTR_PERCENTAGE { get; set; }
        public int FRS_GRADE { get; set; }
        public decimal FRS_PERCENTAGE { get; set; }
        public int LEAD_GRADE { get; set; }
        public decimal LEAD_PERCENTAGE { get; set; }
        public int IB_GRADE { get; set; }
        public decimal IB_PERCENTAGE { get; set; }

    }

}
