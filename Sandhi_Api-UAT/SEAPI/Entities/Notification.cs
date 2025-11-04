using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Entities
{
	public class Notification
    {
        public long Id { get; set; }
        public int Status_Type { get; set; }
        public string Ref_No { get; set; }
        public string Ref_Type { get; set; }
        public long? CSS_Id { get; set; }
        public string User_Id { get; set; }
        public string User_Type { get; set; }
        public string Remarks { get; set; }
        public string Action { get; set; }
        public string Created_User { get; set; }
        public DateTime Created_Date { get; set; }
        public DateTime Expiry_Date { get; set; }
        public bool IsActive { get; set; }
        public DateTime? Email_Date { get; set; }
        public string SUBJECT { get; set; }
        public string Body { get; set; }
        public string ToEmail { get; set; }
    }
}
