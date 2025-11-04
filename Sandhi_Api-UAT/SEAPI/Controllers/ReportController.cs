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
using System.Text;
using SE.API.ResourceParameters;
using Microsoft.Extensions.Configuration;
using Microsoft.AspNetCore.Http;

namespace SE.API.Controllers
{
    [ApiController]
    [Route("[controller]")]
    [ResponseCache(CacheProfileName = "240SecsCacheProfile")]
    [Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    public class ReportController : BaseController
    {


        public ReportController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
            : base(seRepository, mapper, propertyChecker, logger, userManager, config)
        {
        }


        [HttpGet(Name = "GetWorkOrderCount")]
        [Route("GetWorkOrderCount")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetWorkOrderCount([FromQuery] ReportParameter currentParams,
            [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
           
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    currentParams.CssMgrUserId = this.UserModel.Id;
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    currentParams.CssId = Convert.ToInt32(this.UserModel.CSSCode);
                }


                var reportData = _seRepository.GetWorkOrderCounts(currentParams);
                if (reportData == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<Invoice>(currentParams.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                              

                return Ok(reportData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Current Status:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }

        [HttpGet(Name = "GetWorkOrderSemiDraft")]
        [Route("GetWorkOrderSemiDraft")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetWorkOrderSemiDraft([FromQuery] ReportParameter currentParams,
           [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    currentParams.CssMgrUserId = this.UserModel.Id;
                }

                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    currentParams.CssId = Convert.ToInt32(this.UserModel.CSSCode);
                }
                var reportData = _seRepository.GetWorkOrderSemiDraft(currentParams);
                if (reportData == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<Invoice>(currentParams.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }


                return Ok(reportData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Current Status:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }



        [HttpGet(Name = "GetFinanceValidation")]
        [Route("GetFinanceValidation")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetFinanceValidation([FromQuery] ReportParameter currentParams,
           [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    currentParams.CssMgrUserId = this.UserModel.Id;
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    currentParams.CssId = Convert.ToInt32(this.UserModel.CSSCode);
                }


                var reportData = _seRepository.GetFinanceValidation(currentParams);
                if (reportData == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<Invoice>(currentParams.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }


                return Ok(reportData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Current Status:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }
        [HttpGet(Name = "GetNoDueCertificate")]
        [Route("GetNoDueCertificate")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetNoDueCertificate([FromQuery] ReportParameter currentParams,
           [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    currentParams.CssMgrUserId = this.UserModel.Id;
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    currentParams.CssId = Convert.ToInt32(this.UserModel.CSSCode);
                }


                var reportData = _seRepository.GetNoDueCertificate(currentParams);
                if (reportData == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<Invoice>(currentParams.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }


                return Ok(reportData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Current Status:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }

        [HttpGet(Name = "GetCSSInvoice")]
        [Route("GetCSSInvoice")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetCSSInvoice([FromQuery] ReportParameter currentParams,
           [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    currentParams.CssMgrUserId = this.UserModel.Id;
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    currentParams.CssId = Convert.ToInt32(this.UserModel.CSSCode);
                }


                var reportData = _seRepository.GetCSSInvoice(currentParams);
                if (reportData == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<Invoice>(currentParams.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }


                return Ok(reportData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Current Status:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }

        [HttpGet(Name = "GetWODiscrepency")]
        [Route("GetWODiscrepency")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetWODiscrepency([FromQuery] ReportParameter currentParams,
                [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    currentParams.CssMgrUserId = this.UserModel.Id;
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    currentParams.CssId = Convert.ToInt32(this.UserModel.CSSCode);
                }


                var reportData = _seRepository.GetWODiscrepency(currentParams);
                if (reportData == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                if (!_propChecker.TypeHasProperties<Invoice>(currentParams.Fields))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }


                return Ok(reportData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Current Status:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }

        [HttpGet(Name = "GetRegion")]
        [Route("GetRegion")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetRegion([FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }

                var reportData = _seRepository.GetRegion();
                if (reportData == null)
                {
                    return StatusCode(StatusCodes.Status404NotFound);
                }

                

                return Ok(reportData);
            }
            catch (Exception ex)
            {
                _logger.LogError("Error in Get Current Status:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }

    }
}
