using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
	public class ProductCategoryCoolingModel
    {

        public long Id { get; set; }
        public string Type { get; set; }
        public string Product { get; set; }       
        public string Group { get; set; }

    }
}
