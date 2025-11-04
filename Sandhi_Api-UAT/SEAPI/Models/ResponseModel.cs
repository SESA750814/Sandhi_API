using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class ResponseModel
    {
        public int StatusCode { get; set; }

        public string Status { get; set; }

        public string StatusText { get; set; }
        public string Message { get; set; }
    }
}
