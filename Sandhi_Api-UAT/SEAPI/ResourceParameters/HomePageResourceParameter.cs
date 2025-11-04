using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.ResourceParameters
{
    public class HomePageResourceParameter
    {
        private int _pageSize = 40000;
        public string BusinessUnit { get; set; }
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
