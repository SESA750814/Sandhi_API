using AutoMapper;
using Marvin.Cache.Headers;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Cors;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using SE.API.Entities;
using SE.API.Helpers;
using SE.API.Models;
using SE.API.ResourceParameters;
using SE.API.Services;
using SE.API.Utilities;
using System;
using System.Collections.Generic;
using System.Data;
using System.IdentityModel.Tokens.Jwt;
using System.IO;
using System.Linq;
using System.Net.Http.Headers;
using System.Security.Claims;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;

namespace SE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [ResponseCache(CacheProfileName = "240SecsCacheProfile")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public class ImportController : BaseController
    {


        public ImportController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
            : base(seRepository, mapper, propertyChecker, logger, userManager, config)
        {
        }

        [HttpPost(Name = "Import")]
        [Route("Import")]
        public async Task<IActionResult> Import()
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.CentralUser))
                {
                    return Unauthorized();
                }
                var retVal = await _seRepository.StartWOProcessAndImport();
                return StatusCode(StatusCodes.Status201Created);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in import:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = ex.Message, Message = ex.InnerException?.ToString() });
            }
        }


       
        [HttpPost(Name = "WOImportAndProcess")]
        [Route("WOImportAndProcess")]
        public async Task<IActionResult> WOImportAndProcess([FromBody] ExcelImportParameter model)
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.CentralUser))
                {
                    return Unauthorized();
                }
                if (ModelState.IsValid)
                {
                    bool processFile = (_config.GetSection("ExcelImport").GetValue<String>("ProcessFile") ?? "") == "YES";
                    if (processFile)
                    {
                        var retVal = _seRepository.ExcelImport(model.FileName, model.TableName, _config, _logger);
                        if (!retVal)
                        {
                            return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error in the First File" });
                        }


                        if (!string.IsNullOrEmpty(model.AdditionalFileName) && !string.IsNullOrEmpty(model.AdditionalTableName))
                        {

                            retVal = _seRepository.ExcelImport(model.AdditionalFileName, model.AdditionalTableName, _config, _logger);
                            if (!retVal)
                            {
                                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error in the Additional File" });
                            }
                        }
                        bool isJob = (_config.GetSection("ExcelImport").GetValue<String>("IsJob") ?? "") == "YES";
                        retVal = await _seRepository.StartWOProcessAndImport(isJob);
                        if (retVal)
                        {

                            return StatusCode(StatusCodes.Status200OK);
                        }
                    }
                    else
                    {
                        return StatusCode(StatusCodes.Status200OK, new ResponseModel { Status = "Files are being processed. An Email will be sent to you with the status." });

                    }

                }
                return StatusCode(StatusCodes.Status400BadRequest);
            }
            catch (Exception ex)
            {

                _logger.LogError("Error in excel import and process:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                Email.SendEmail(_config, _logger, "FILE IMPORT ERROR", "Error when uploading file -" + ex.Message, _config.GetSection("Email").GetValue<String>("CentralEmail"));

                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = ex.Message, Message = ex.InnerException?.ToString() });
            }
        }

      


        [HttpPost(Name = "ImportAndProcessPurchaseOrder")]
        [Route("ImportAndProcessPurchaseOrder")]
        public async Task<IActionResult> ImportAndProcessPurchaseOrder(ExcelImportParameter model)
        {
            try
            {
                if ((this.UserModel.UserType ?? -1) != ((int)UserType.CentralUser))
                {
                    return Unauthorized();
                }
                if (ModelState.IsValid)
                {

                    var retVal = _seRepository.ExcelImport(model.FileName, "Purchase_Order_Import", _config, _logger);
                    if (!retVal)
                    {
                        return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error in the First File" });
                    }

                    retVal = await _seRepository.ImportPurchaseOrder();
                    if (retVal)
                    {

                        return StatusCode(StatusCodes.Status200OK);
                    }

                }
                return StatusCode(StatusCodes.Status400BadRequest);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in PO import:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = ex.Message, Message = ex.InnerException?.ToString() });
            }
        }



        [HttpPost(Name = "ImportAndProcessGradation")]
        [Route("ImportAndProcessGradation")]
        public async Task<IActionResult> ImportAndProcessGradation(ExcelImportParameter model)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    //to-do should only be central login

                    if ((this.UserModel.UserType ?? -1) != ((int)UserType.CentralUser))
                    {
                        return Unauthorized();
                    }
                    var gradationFiles = _config.GetSection("ExcelImport").GetValue<String>("GradationFiles");
                    foreach (string file in gradationFiles.Split(",").ToList())
                    {

                        var retVal = _seRepository.ExcelImport(file + ".xlsx", file, _config, _logger);
                        if (!retVal)
                        {
                            return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = "Error in the File -" + file });
                        }
                    }

                    var gradeRetVal = await _seRepository.CalculateGradation();
                    if (gradeRetVal)
                    {

                        return StatusCode(StatusCodes.Status200OK, new ResponseModel { Status = "Gradation uploaded successfully!!!" });
                    }

                }
                return StatusCode(StatusCodes.Status400BadRequest);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Gradation import:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                return StatusCode(StatusCodes.Status500InternalServerError, new ResponseModel { Status = ex.Message, Message = ex.InnerException?.ToString() });
            }
        }
    }
}
