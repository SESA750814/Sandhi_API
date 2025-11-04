using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class LinkDTO
    {
        public string HRef { get; set; }
        public string Rel { get; set; }
        public string Method { get; set; }


        public LinkDTO(string href, string rel, string method)
        {
            HRef = href;
            Rel = rel;
            Method = method;
        }
    }
}
