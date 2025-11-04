using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models

{
    public class InvoiceTransitionAction
    {
        public Action<Invoice> UpdateInvoiceFields { get; set; }
        public Func<InvoiceStatus> CreateStatusEntry { get; set; }

    }
}
