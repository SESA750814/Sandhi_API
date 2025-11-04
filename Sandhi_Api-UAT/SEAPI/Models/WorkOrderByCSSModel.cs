using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models

{
    public class WorkOrderByCSSModel
    {
        public long Id { get; set; }
        public string Region { get; set; }
        public string CSS_Code { get; set; }
        public string CSS_Name { get; set; }
        public string Vendor_Code { get; set; }
        public string Email_ID { get; set; }
        public string Business_Unit { get; set; }
        public string City_Location { get; set; }
        public string Primary_Contact_Person { get; set; }
        public string Phone_Number { get; set; }
        public string Grade { get; set; }
        public string Month_Name { get; set; }
        public decimal? Base_Payout_Percentage { get; set; }
        public decimal? Incentive_Percentage { get; set; }
        public DateTime Submitted_Date { get; set; }
        public int WorkOrderCount { get; set; }
        public IEnumerable<WorkOrderModel> WorkOrders { get; set; }
    }
}
