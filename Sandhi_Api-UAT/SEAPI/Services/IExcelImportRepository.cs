using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SE.API.Entities;
using SE.API.Helpers;
using SE.API.ResourceParameters;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace SE.API.Services
{
    public interface IExcelImportRepository
    {


        bool ImportFile(string fileName, string tableName, IConfiguration _config, ILogger _logger);
        bool Save();
        void AddEntity(object model);
        void UpdateEntity(object model);
        void RemoveEntity(object model);
        bool RawDumpImportFile(string fileName, string tableName, IConfiguration _config, ILogger _logger);

        //List<T> ExcelOrCSVDatas<T>(string fileName, IConfiguration _config, ILogger _logger) where T : class, new();
    }
}
