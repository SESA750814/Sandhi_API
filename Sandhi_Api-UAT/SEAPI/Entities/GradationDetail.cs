using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Entities
{
    public class GradationDetail
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public long Id { get; set; }
        [ForeignKey("Gradation")]
        public long GRADATION_ID { get; set; }

        public string GRADE_TYPE { get; set; }
        public string CITY_CLASS { get; set; }
        public string BUSINESS_UNIT { get; set; }

        //[Column(TypeName = "decimal(18,2)")]
        public string GRADE_SCORE { get; set; }
        public string GRADE { get; set; }
        public string UPDATED_USER { get; set; }
        public DateTime UPDATED_DATE { get; set; }

        public Gradation Gradation { get; set; }

    }

}
