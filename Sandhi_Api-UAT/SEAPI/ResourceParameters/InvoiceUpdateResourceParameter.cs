using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.ResourceParameters
{
    public class InvoiceUpdateResourceParameter
    {
        private int _pageSize = 40000;
        public string BusinessUnit { get; set; }
        public string UserName { get; set; }
        public long? CSSId { get; set; }
        public int? StatusType { get; set; }
        public long? InvId { get; set; }

        public string InvIds { get; set; }

        /****** Update Values ************/

        public string RefNo { get; set; }
        public DateTime? RefDate { get; set; }
        public string InvAttachment { get; set; }

        public decimal? InvAmount { get; set; }


        public string Remarks { get; set; }


        public DateTime? NoDueDate { get; set; }
        public string NoDueAttachment { get; set; }

        public DateTime? PaidDate { get; set; }

        /****** Update Values Ends************/



        public int PageNumber { get; set; } = 1;
        public int PageSize
        {
            get => _pageSize;
            set => _pageSize = (value > 40000 ? 40000 : value);
        }

        public string Fields { get; set; }
    }
}
