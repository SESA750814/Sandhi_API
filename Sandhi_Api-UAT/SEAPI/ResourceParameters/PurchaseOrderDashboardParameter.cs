using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.ResourceParameters
{
    public class PurchaseOrderDashboardParameter
    {
        private int _pageSize = 40000;
        public int PageNumber { get; set; } = 1;

        public string Region { get; set; }
        public string CSSManagerUserId { get; set; }
        public string FinUserId { get; set; }
        public string GRNUserId { get; set; }
        public string CSSId { get; set; }
        public int PageSize
        {
            get => _pageSize;
            set => _pageSize = (value > 40000 ? 40000 : value);
        }

        public string Fields { get; set; }
    }
}
