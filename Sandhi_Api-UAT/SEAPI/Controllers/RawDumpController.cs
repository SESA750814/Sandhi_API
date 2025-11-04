using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using SE.API.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SE.API.Services;

namespace SE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [ResponseCache(CacheProfileName = "240SecsCacheProfile")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public class RawDumpController : ControllerBase
    {
        private readonly IConfiguration _config;
        private ILogger<WorkOrderRepository> _logger;
        public RawDumpController(IConfiguration config, ILogger<WorkOrderRepository> logger)
        {
            _config = config;
            _logger = logger;
        }
        [HttpPost]
        public IActionResult UploadFile([FromForm] FileModel file)
        {
            try
            {
                //string path = Path.Combine(Directory.GetCurrentDirectory(), "RawDumpUpload", file.FileName);
                string path = Path.Combine(_config["ExcelImport:Folder"], file.FileName);
                _logger.LogInformation("Path where RawDump file is uploaded: " + path);
                if (System.IO.File.Exists(path))
                {
                    _logger.LogInformation("Going to delete existing RawDump file.");
                    System.IO.File.Delete(path);
                    _logger.LogInformation("Delete of existing RawDump file is successful");
                }
                using(Stream stream = new FileStream(path, FileMode.Create))
                {
                    _logger.LogInformation("Going to copy new RawDump file.");
                    file.FormFile.CopyTo(stream);
                    _logger.LogInformation("Copy of new RawDump file is successful");
                }
                return StatusCode(StatusCodes.Status201Created);
            }
            catch (Exception ex)
            {
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = ex.Message, Message = ex.InnerException?.ToString() });
            }
        }

    }
}
