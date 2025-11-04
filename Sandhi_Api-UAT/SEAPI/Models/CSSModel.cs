using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models

{
    public class CSSModel
    {
        public long Id { get; set; }

        public string Region { get; set; }
        public string CSS_Name_as_per_Oracle_SAP { get; set; }
        public string CSS_Name_in_bFS_to_be_referred { get; set; }
        public string CSS_Manager { get; set; }
        public string Vendor_Code { get; set; }
        public string CSS_Code { get; set; }
        public string Email_ID { get; set; }
        public string Pay_out_Type { get; set; }
        public string Pay_out_Structure { get; set; }
        public string Business_Unit { get; set; }
        public string City_Location { get; set; }
        public string State { get; set; }
        public string CSS_Country { get; set; }
        public string Finance_Claim_Data_Validator { get; set; }
        public string Invoice_Validator_from_Finance_Team { get; set; }
        public string HBN_WARRANTY { get; set; }
        public string HBN_AMC { get; set; }
        public string AMC_LABOR { get; set; }
        public string AMC_SUPPLY { get; set; }
        public string WARRANTY_LABOR { get; set; }
        public string WARRANTY_SUPPLY { get; set; }
        public string PO { get; set; }
        public string WH_Location { get; set; }
        public string PO_Type { get; set; }
        public string CSS_City_Class { get; set; }
        public string CSS_MGR_USER_ID { get; set; }
        public string INV_FIN_USER_ID { get; set; }
        public string CLAIM_FIN_USER_ID { get; set; }

        public string Primary_Contact_Person { get; set; }
        public string Phone_Number { get; set; }
        public string Authorised_UserEmail { get; set; }
        public string Grade { get; set; }
        public decimal? Base_Payout_Percentage { get; set; }
        public decimal? Incentive_Percentage { get; set; }
        public string Zip_Code { get; set; }
        public IEnumerable<WorkOrderModel> WorkOrders { get; set; }

        // GRN and SCM added
        public string GRN_Creater_Email_ID { get; set; }
         
    }
}
