using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.ResourceParameters
{
    public class ReportParameter
    {
        private int _pageSize = 40000;
        public string FromDate { get; set; }
        public string ToDate { get; set; }
        public int? CssId { get; set; }
        public string BusinessUnit { get; set; }
        public string Region { get; set; }

        public char ReportType { get; set; }
        public string FinUserId { get; set; }
        public string CssMgrUserId { get; set; }
        public string GrnUserId { get; set; }
        public int PageNumber { get; set; } = 1;
        public int PageSize
        {
            get => _pageSize;
            set => _pageSize = (value > 40000 ? 40000 : value);
        }

        public string Fields { get; set; }
    }
}
