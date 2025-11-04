using System;
using System.Collections.Generic;

namespace SE.API.Models
{
    public class InvoiceSummaryResponseModel
    {
        public OverallSummary Overall { get; set; }
        public List<MonthlyData> MonthlyData { get; set; }
        public DateRangeInfo DateRange { get; set; }
        public List<InvoiceSummaryDataDetail> PendingInvoices { get; set; }
    }

    public class OverallSummary
    {
        public int Expected { get; set; }
        public int Actual { get; set; }
        public int Cleared { get; set; }
        public int Pending { get; set; }
        public double PctReceived { get; set; }
        public double PctCleared { get; set; }
        public double PctPending { get; set; }
    }

    public class MonthlyData
    {
        public int Year { get; set; }
        public int Month { get; set; }
        public int Cleared { get; set; }
        public int PendingInvoices { get; set; }
    }

    public class DateRangeInfo
    {
        public string FromDate { get; set; }
        public string ToDate { get; set; }
        public string FromMonth { get; set; }
        public string ToMonth { get; set; }
    }
    public class InvoiceSummaryDataDetail
    {
        public string InvoiceNumber { get; set; }
        public DateTime? PaymentDueDate { get; set; }
        public int Status { get; set; }
        public string Month { get; set; }

    }
}

