using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Entities
{
    public class WorkOrder
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }
        [Required]
        public string WO_BusinessUnit { get; set; }
        [Required]
        [MaxLength(50)]
        public string Work_Order_Number { get; set; }

        [ForeignKey("CSS")]
        public long CSS_Id { get; set; }
        public string Case { get; set; }
        [MaxLength(50)]
        public string PRF_Number { get; set; }
        public string First_Assigned_DateTime { get; set; }
        public string Customer_Requested_Date { get; set; }
        public string FSR_Internal_Comments { get; set; }
        public string WO_Created_Date_Time { get; set; }
        public string Main_Installed_Product { get; set; }
        public string Product { get; set; }
        public string Product_Commercial_Reference { get; set; }
        [MaxLength(10)]
        public string Product_Grouping { get; set; }
        public string IP_Serial_Number { get; set; }
        public string Work_Order_Reason { get; set; }
        public string Work_Order_Created_Date { get; set; }
        public string Completed_On { get; set; }
        public string Is_Billable { get; set; }
        public bool? Is_RepeatCall_NonMaterial { get; set; }
        public string Non_Billing_Reason { get; set; }
        public string Installed_At_Account { get; set; }
        public string Street { get; set; }
        public string City { get; set; }
        public string Zip { get; set; }
        public string State { get; set; }
        public string Service_Team { get; set; }
        public string Primary_FSR { get; set; }
        public string Partner_Account { get; set; }
        public string Partner_Account_Rv { get; set; }
        public string Work_Performed { get; set; }
        public string Work_Order_Type { get; set; }
        public string Contact { get; set; }
        public string Contact_Phone { get; set; }
        public string Work_Order_Sub_Type { get; set; }
        public string Work_Order_Status { get; set; }
        public string WO_Completed_Timestamp { get; set; }
        public string Comments_to_Planner { get; set; }
        public string Special_Instructions { get; set; }
        public int? Actual_Expense_converted { get; set; }
        public string Actual_Expense_converted_Currency { get; set; }
        [Required]
        public string Actual_Expense { get; set; }
        public string Claim_Type { get; set; }
        public string Branch_Code { get; set; }
        public string Payout_Type { get; set; }
        public string Region { get; set; }
        public string Call_type { get; set; }
        public string Call_type_rv { get; set; }
        public bool? IsMaterialUsed { get; set; }
        public string PRODUCT_CATEGORY { get; set; }
        public string Distance_Slab { get; set; }
        public string Repeat_Yes_No { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? Claim { get; set; }
        public string Remarks { get; set; }
        public string Region_Remarks { get; set; }
        public string Bill_Cycle { get; set; }
        public string Business_Unit { get; set; }
        public string DS_Code { get; set; }
        public string MaterialUsed { get; set; }

        /************** Columns only used in Cooling *******************/
        public bool? Is_Expenses_Mileage { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? Actual_Expenses_Mileage { get; set; }
        public bool? Is_Expenses_Gas { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? Actual_Expenses_Gas { get; set; }
        public bool? Is_Expenses_Supplies { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? Actual_Expenses_Supplies { get; set; }


        [Column(TypeName = "decimal(18,2)")]
        public decimal? LABOUR_COST { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? SUPPLY_COST { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? ACTUAL_LABOUR_COST { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? ACTUAL_SUPPLY_COST { get; set; }
        public string LABOUR_DESC { get; set; }
        public string SUPPLY_DESC { get; set; }
        public string MILEAGE_DESC { get; set; }
        /************** Columns only used in Cooling Ends *******************/



        [Column(TypeName = "decimal(18,2)")]
        public decimal? Actual_Cost { get; set; }
        public string AMC_WARRANTY_FLAG { get; set; }


        public bool? Central_Status { get; set; }
        public DateTime? Central_UpdatedDate { get; set; }
        public string Central_User { get; set; }


        public bool? CSS_Status { get; set; }
        public DateTime? CSS_UpdatedDate { get; set; }
        public string CSS_User { get; set; }
        public string CSS_Remark { get; set; }
        public string CSS_Reason { get; set; }
        public string CSS_Reason_Desc { get; set; }
        public string CSS_Attachment { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? CSS_Cost { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? CSS_LABOUR_COST { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? CSS_SUPPLY_COST { get; set; }
        public DateTime? CSS_Approved_Date { get; set; }



        public bool? CSS_Mgr_Status { get; set; }
        public DateTime? CSS_Mgr_UpdatedDate { get; set; }
        public string CSS_Mgr_User { get; set; }
        public string CSS_Mgr_Remark { get; set; }
        public string CSS_Mgr_Reason { get; set; }
        public string CSS_Mgr_Reason_Desc { get; set; }
        public string CSS_Mgr_Attachment { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? CSS_Mgr_Cost { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? CSS_Mgr_LABOUR_COST { get; set; }

        [Column(TypeName = "decimal(18,2)")]
        public decimal? CSS_Mgr_SUPPLY_COST { get; set; }

        public long WO_Process_Status { get; set; }
        [ForeignKey("Invoice")]
        public long? INV_ID { get; set; }
        [ForeignKey("SupplyInvoice")]
        public long? SUPPLY_INV_ID { get; set; }

        public string User_ID { get; set; }

        public DateTime? Update_Date_Time { get; set; }

        public DateTime Loaded_Date { get; set; }
        public string WO_Month { get; set; }
        public string WO_Year { get; set; }
        [MaxLength(50)]
        public string Month_Name { get; set; }
        public CSS CSS { get; set; }
        public Invoice Invoice { get; set; }
        public Invoice SupplyInvoice { get; set; }

        [InverseProperty("WorkOrder")]
        public ICollection<WorkOrderStatus> WorkOrderStatuses { get; set; }

    }
}
