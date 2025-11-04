using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

// Code scaffolded by EF Core assumes nullable reference types (NRTs) are not used or disabled.
// If you have enabled NRTs for your project, then un-comment the following line:
// #nullable disable

namespace SE.API.Entities
{
    public partial class Cooling_Rate_Card
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public int Id { get; set; }
        public string Sr_no { get; set; }
        public string Payout_Type { get; set; }
        public string Work_Description { get; set; }
        public string Description { get; set; }
        public string Short_Description { get; set; }
        public string Unit_details { get; set; }
        public string Product_Grouping { get; set; }
        public string CSS_Code { get; set; }
        public string Region { get; set; }
        public string Distance_Slab { get; set; }
        public string Rate { get; set; }
    }
}
