using SE.API.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.Models
{
	public class UploadErrorsModel
    {
        public long Id { get; set; }
        public long CSS_Id { get; set; }
        public string Guid { get; set; }
        public string File_Name { get; set; }
        public string Error_Information { get; set; }
        public DateTime? TimeStamp { get; set; }
    }
}
