using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class GradationDashboardModel
    {
        public List<GradationDashboardCSSModel> GradationByCss { get; set; }
        public List<GradationDashboardGroupModel> GradationByGroup { get; set; }
        public List<GradationDashboardGroupModel> GradationByRegion { get; set; }

    }

}
