using AutoMapper;
using SE.API.Entities;
using SE.API.Helpers;
using SE.API.Models;
using SE.API.Services;
using Marvin.Cache.Headers;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.JsonPatch;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Identity;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Configuration;
using System.Text;
using SE.API.ResourceParameters;
using System.IO;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Hosting;
using DocumentFormat.OpenXml.Packaging;
using DocumentFormat.OpenXml.Spreadsheet;
using DocumentFormat.OpenXml;
using System.Globalization;

namespace SE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [ResponseCache(CacheProfileName = "240SecsCacheProfile")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public class ExcelController : ControllerBase
    {
        private IWorkOrderRepository _seRepository;
        private IMapper _mapper;
        private IPropertyCheckerService _propChecker;
        private UserManager<StoreUser> _userManager;
        private SignInManager<StoreUser> _signInManager;
        private readonly IConfiguration _config;

        private ILogger<WorkOrderRepository> _logger;
        // Sorting  is ignored here if needed look at ways to do it...
        // think sorting can be achieved by extension method
        // implementing shaping

        public ExcelController(UserManager<StoreUser> userManager, SignInManager<StoreUser> signInManager,
            IWorkOrderRepository libraryRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, IConfiguration config)
        {
            _seRepository = libraryRepository ?? throw new ArgumentNullException(nameof(libraryRepository));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _mapper = mapper ?? throw new ArgumentNullException(nameof(mapper));
            _propChecker = propertyChecker ?? throw new ArgumentNullException(nameof(propertyChecker));
            _userManager = userManager;
            _signInManager = signInManager;
            _config = config;
        }

        [HttpPost(Name = "ExcelImport")]
        [Route("ExcelImport")]
        public IActionResult ExcelImport(ExcelImportParameter model)
        {
            try
            {
                if (ModelState.IsValid)
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
                    if (retVal)
                    {
                        return StatusCode(StatusCodes.Status200OK);
                    }

                }
                return StatusCode(StatusCodes.Status400BadRequest);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Excel import:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                return StatusCode(StatusCodes.Status400BadRequest);
            }
        }

    }
}
