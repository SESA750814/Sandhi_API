using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class ReportNoDueCertificate
    {
        public string Css_Code { get; set; }
        public string CSS_Name { get; set; }
        public string Region { get; set; }
        public string BusinessUnit { get; set; }
        public string LastNoDueDate { get; set; }
        public string LastNoDueMonths { get; set; }
        public string PendingMonths { get; set; }

    }

}
