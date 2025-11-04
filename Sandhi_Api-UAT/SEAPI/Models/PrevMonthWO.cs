using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class PrevMonthWO
    {
        public string MonthName { get; set; }
        public long TotalWorkOrders { get; set; }
        public long HBNWorkOrders{ get; set; }
        public long PPIWorkOrders { get; set; }
        public long CoolingWorkOrders { get; set; }

        public DateTime LoadedDate { get; set; }
        public long WoProcessStatus { get; set; }
    }
}
