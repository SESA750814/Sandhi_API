// Decompiled with JetBrains decompiler
// Type: SE.API.Models.InvoiceUpdateDetails
// Assembly: SE.API, Version=1.0.0.0, Culture=neutral, PublicKeyToken=null
// MVID: 0D5C8F72-A166-4D11-9585-9D9E8F3779FF
// Assembly location: D:\work\SandiApps\SE.API.dll

using CsvHelper.Configuration.Attributes;
using System.ComponentModel.DataAnnotations;

namespace SE.API.Models
{
    public class PPI_InvoiceUpdateDetails
    {
        [Index(0, -1)]
        [Required]
        public string Vendor { get; set; }

        [Index(1, -1)]
        [Required]
        public string Reference { get; set; } // invoice number

        [Index(2, -1)]
        [Required]
        public string Vendorname { get; set; }

        [Index(17, -1)]
        [Required]
        public string BusinessUnit { get; set; }
    }

    public class InvoiceUpdateDetails
    {
        [Index(0, -1)]
        public string CSSCode { get; set; }

        [Index(1, -1)]
        public string PartnerName { get; set; }

        [Index(2, -1)]
        public string SubmitedDate { get; set; }

        [Index(3, -1)]
        [Required]
        public string BusinessUnit { get; set; }

        [Index(4, -1)]
        [Required]
        public int CssId { get; set; }

        [Index(5, -1)]
        [Required]
        public int InvoiceId { get; set; }

        [Index(6, -1)]
        public string InvoiceNumber { get; set; }

        [Index(7, -1)]
        public string InvoiceDate { get; set; }

        [Index(8, -1)]
        public string PoNumber { get; set; }

        [Index(9, -1)]
        public string GRNNo { get; set; }

        [Index(10, -1)]
        public string PRFNumber { get; set; }

        [Index(11, -1)]
        public string Region { get; set; }

        [Index(12, -1)]
        public string TotalAmountwithTax { get; set; }

        [Index(13, -1)]
        public string InvoiceAmount { get; set; }

        [Index(14, -1)]
        [Required]
        public string PaidDate { get; set; }

        [Index(15, -1)]
        [Required]
        public string Status { get; set; }
    }
}
