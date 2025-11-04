using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
	public class ApprovedDataWorkOrderModel
    {
        public long Id { get; set; }

        public long Approved_Id { get; set; }
        public string WO_BusinessUnit { get; set; }
        public string Work_Order_Number { get; set; }
        public string Installed_At_Account { get; set; }
        public string Month_Name { get; set; }
        public string Work_Order_Type { get; set; }
        public string WO_Completed_Date { get; set; }
        public decimal? Claim { get; set; }
        public decimal? Labour_Cost { get; set; }
        public decimal? Supply_Cost { get; set; }
        public string Gid { get; set; }



        public string Case { get; set; }
        public string First_Assigned_DateTime { get; set; }
        public string Main_Installed_Product { get; set; }
        public string IP_Serial_Number { get; set; }
        public string Product_Grouping { get; set; }
        public string Work_Order_Sub_Type { get; set; }
        public string Completed_On { get; set; }
        public string Work_Order_Reason { get; set; }
        public string Product { get; set; }
        public string Is_Billable { get; set; }
        public string Non_Billing_Reason { get; set; }
        public string Street { get; set; }
        public string City { get; set; }
        public string Zip { get; set; }
        public string State { get; set; }
        public string Service_Team { get; set; }
        public string Primary_FSR { get; set; }
        public string Partner_Account { get; set; }
        public string Work_Performed { get; set; }
        public long WO_Process_Status { get; set; }
        public string Distance_Slab { get; set; }
        public int? Actual_Expense_converted { get; set; }
        public string WO_Completed_Timestamp { get; set; }
        public string Claim_Type { get; set; }
        public string LABOUR_DESC { get; set; }
        public string SUPPLY_DESC { get; set; }
        public string MILEAGE_DESC { get; set; }
        public decimal? Actual_Expenses_Mileage { get; set; }
        public decimal? Actual_Expenses_Gas { get; set; }
        public decimal? Actual_Expenses_Supplies { get; set; }
        public decimal? Actual_Cost { get; set; }
        public decimal? ACTUAL_LABOUR_COST { get; set; }
        public decimal? ACTUAL_SUPPLY_COST { get; set; }
        public string CSS_Reason { get; set; }


    }
}
