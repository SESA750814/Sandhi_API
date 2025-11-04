using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.ResourceParameters
{
    public class NotificationResourceParameter
    {
        private int _pageSize = 40000;
        public string UserType { get; set; }
        public string UserId { get; set; }
        public Int64? CSSId { get; set; }

        public Int64? NotificationId { get; set; }
        public string IsEmail { get; set; }
        public int PageNumber { get; set; } = 1;
        public int PageSize
        {
            get => _pageSize;
            set => _pageSize = (value > 40000 ? 40000 : value);
        }

        public string Fields { get; set; }
    }
}
