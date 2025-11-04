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
    public class DashboardController : BaseController
    {


        public DashboardController(IWorkOrderRepository seRepository, IMapper mapper, IPropertyCheckerService propertyChecker,
            ILogger<WorkOrderRepository> logger, UserManager<StoreUser> userManager, IConfiguration config)
            : base(seRepository, mapper, propertyChecker, logger, userManager, config)
        {
        }


        [HttpGet(Name = "GetGradation")]
        [Route("GetGradation")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetGradation([FromQuery] GradationDashboardParameter currentParams,
            [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    currentParams.CSSId = this.UserModel.CSSCode;
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    currentParams.CSSManagerUserId = this.UserModel.Id;
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.SCMUser))
                {
                    currentParams.GRNUserId = this.UserModel.Id;
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.FinanceUser))
                {
                    currentParams.FinUserId = this.UserModel.Id;
                }



                var reportData = _seRepository.GetGradationDashboard(currentParams);
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
                _logger.LogError("Error in GetGradation:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }
        [HttpGet(Name = "GetPaymentByCount")]
        [Route("GetPaymentByCount")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetPaymentByCount([FromQuery] PaymentDashboardParameter currentParams,
         [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    currentParams.CSSId = this.UserModel.CSSCode;
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    currentParams.CSSManagerUserId = this.UserModel.Id;
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.SCMUser))
                {
                    currentParams.GRNUserId = this.UserModel.Id;
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.FinanceUser))
                {
                    currentParams.FinUserId = this.UserModel.Id;
                }



                var reportData = _seRepository.GetPaymentDashboardByCount(currentParams);
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
                _logger.LogError("Error in GetPaymentByCount:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }
        [HttpGet(Name = "GetPaymentByValue")]
        [Route("GetPaymentByValue")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetPaymentByValue([FromQuery] PaymentDashboardParameter currentParams,
         [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    currentParams.CSSId = this.UserModel.CSSCode;
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    currentParams.CSSManagerUserId = this.UserModel.Id;
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.SCMUser))
                {
                    currentParams.GRNUserId = this.UserModel.Id;
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.FinanceUser))
                {
                    currentParams.FinUserId = this.UserModel.Id;
                }



                var reportData = _seRepository.GetPaymentDashboardByValue(currentParams);
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
                _logger.LogError("Error in GetPaymentByValue:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }
        [HttpGet(Name = "GetPurchaseOrder")]
        [Route("GetPurchaseOrder")]
        [ResponseCache(Duration = 120)]
        [HttpCacheExpiration(CacheLocation = CacheLocation.Private, MaxAge = 60)]
        [HttpCacheValidation(MustRevalidate = false)]
        public IActionResult GetPurchaseOrder([FromQuery] PurchaseOrderDashboardParameter currentParams,
         [FromHeader(Name = "Accept")] string contentType)
        {
            try
            {

                if (!MediaTypeHeaderValue.TryParse(contentType, out MediaTypeHeaderValue parsedMediaType))
                {
                    return StatusCode(StatusCodes.Status400BadRequest);
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSUser))
                {
                    currentParams.CSSId = this.UserModel.CSSCode;
                }
                if ((this.UserModel.UserType ?? -1) == ((int)UserType.CSSManager))
                {
                    currentParams.CSSManagerUserId = this.UserModel.Id;
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.SCMUser))
                {
                    currentParams.GRNUserId = this.UserModel.Id;
                }
                else if ((this.UserModel.UserType ?? -1) == ((int)UserType.FinanceUser))
                {
                    currentParams.FinUserId = this.UserModel.Id;
                }



                var reportData = _seRepository.GetPurchaseOrderDashboard(currentParams);
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
                _logger.LogError("Error in GetPurchaseOrder:" + ex.Message + "***Inner Exception***" + ex.InnerException?.ToString());
                throw ex;
            }
        }
    }
}
