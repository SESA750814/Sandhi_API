using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class InvoiceFilter
    {
        public string? PRF_Invoice_No { get; set; }
        public string? Invoice_Type { get; set; }
        public int? Invoice_Status { get; set; }
        public string? Bussines_Unit { get; set; }
        public string? Month_Name { get; set; }

    }
}
