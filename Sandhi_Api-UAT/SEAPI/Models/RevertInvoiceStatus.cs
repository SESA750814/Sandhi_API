using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
    public class RevertInvoiceStatus
    {
        public List<long>? WorkOrderId { get; set; }
        public long? Inv_Id { get; set; }
        public int? To_Status { get; set; }
        public int From_Status { get; set; }
    }
}
