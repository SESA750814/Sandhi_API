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
    public class FileController : ControllerBase
    {
        private readonly IConfiguration _config;
        private ILogger<WorkOrderRepository> _logger;
        public FileController(IConfiguration config, ILogger<WorkOrderRepository> logger)
        {
            _config = config;
            _logger = logger;
        }
        [HttpPost]
        public IActionResult UploadFile([FromForm] FileModel file)
        {
            try
            {
                
                string path = Path.Combine(_config["ExcelImport:Folder"], file.FileName);
                if (System.IO.File.Exists(path))
                {
                    System.IO.File.Delete(path);
                    _logger.LogInformation("step 1 : Path where admin file is exist then delete: " + path);
                }
                using(Stream stream = new FileStream(path, FileMode.Create))
                {
                    file.FormFile.CopyTo(stream);
                    _logger.LogInformation("step 2 : Path where admin file is uploade at folder: " + path);

                }
                path = Path.Combine(Directory.GetCurrentDirectory(), "Upload", file.FileName);
                if (System.IO.File.Exists(path))
                {
                    System.IO.File.Delete(path);
                    _logger.LogInformation("step 3 : Path where admin file is exist then delete: " + path);

                }
                using (Stream stream = new FileStream(path, FileMode.Create))
                {
                    file.FormFile.CopyTo(stream);
                    _logger.LogInformation("step 4 : Path where admin file is uploade at upload: " + path);
                }
                path = Path.Combine(_config["ExcelImport:UploadFolder"], file.FileName);
                if (System.IO.File.Exists(path))
                {
                    System.IO.File.Delete(path);
                    _logger.LogInformation("step 5 : Path where admin file is exist then delete: " + path);
                }
                using (Stream stream = new FileStream(path, FileMode.Create))
                {
                    file.FormFile.CopyTo(stream);
                    _logger.LogInformation("step 6 : Path where admin file is uploade at upload: " + path);
                }
                return StatusCode(StatusCodes.Status201Created);
            }
            catch (Exception ex)
            {
                _logger.LogError("step 999 : error at file uploading: Message -> " + ex.Message + " InnerException -> " + ex.InnerException?.ToString());
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = ex.Message, Message = ex.InnerException?.ToString() });
            }
        }


    }
}
