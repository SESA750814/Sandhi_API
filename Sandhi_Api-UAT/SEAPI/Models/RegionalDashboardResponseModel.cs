using System.Collections.Generic;

namespace SE.API.Models
{
    public class RegionalDashboardResponseModel
    {
        public List<BusinessUnitSummary> BusinessUnits { get; set; }
        public DateRangeInfo DateRange { get; set; }
    }

    public class BusinessUnitSummary
    {
        public string BusinessUnit { get; set; }
        public OverallSummary Overall { get; set; }
        public List<RegionalSummary> Regions { get; set; }
    }

    public class RegionalSummary
    {
        public string Region { get; set; }
        public List<string> Spocs { get; set; }
        public int Expected { get; set; }
        public int Actual { get; set; }
        public int Cleared { get; set; }
        public double PctReceived { get; set; }
        public double PctCleared { get; set; }
    }

}
