using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace SE.API.ResourceParameters
{
    public class ExcelImportParameter
    {
        public string FileName { get; set; }
        public string TableName { get; set; }

        public string AdditionalFileName { get; set; }
        public string AdditionalTableName { get; set; }

    }
}
