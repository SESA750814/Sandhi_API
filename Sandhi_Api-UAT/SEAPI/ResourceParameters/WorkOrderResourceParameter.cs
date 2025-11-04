using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.ResourceParameters
{
    public class WorkOrderResourceParameter
    {
        private int _pageSize = 40000;
        public string Month { get; set; }
        public string WorkOrderNumber { get; set; }
        public string BusinessUnit { get; set; }
        public List<Int64> CSSIds { get; set; }
        public List<string> Statuses { get; set; }
        public long? InvId { get; set; }
        public int UserType { get; set; }
        public int PageNumber { get; set; } = 1;
        public int PageSize
        {
            get => _pageSize;
            set => _pageSize = (value > 40000 ? 40000 : value);
        }

        public string Fields { get; set; }
    }
}
