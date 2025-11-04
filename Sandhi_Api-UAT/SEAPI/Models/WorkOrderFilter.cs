using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class WorkOrderFilter
    {
        public int? WorkOrder_Status { get; set; }
        public string? Bussines_Unit { get; set; }
        public string? Month_Name { get; set; }
    }
}
