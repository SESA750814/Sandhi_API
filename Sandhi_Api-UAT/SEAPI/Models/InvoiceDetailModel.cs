using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class InvoiceDetailModel
    {
        public long Id { get; set; }
        public long Inv_Id { get; set; }
        public string AMC_Warranty_Flag { get; set; }
        public decimal INV_Amt { get; set; }
        public string Updated_User { get; set; }
        public DateTime Updated_Date { get; set; }
    }
}
